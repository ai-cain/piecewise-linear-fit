#include "AppController.h"

#include "SegmentFitService.h"

#include <QFile>
#include <QFileInfo>
#include <QRegularExpression>
#include <QTextStream>
#include <QUrl>

#include <cmath>

namespace
{
QString formatNumber(double value, int decimals = 7)
{
    if (std::abs(value) < 1e-12) {
        value = 0.0;
    }

    QString text = QString::number(value, 'f', decimals);
    while (text.contains('.') && (text.endsWith('0') || text.endsWith('.'))) {
        if (text.endsWith('.')) {
            text.chop(1);
            break;
        }

        text.chop(1);
    }

    return text;
}

bool parseNumber(QString text, double &value)
{
    text = text.trimmed();
    if (text.isEmpty()) {
        return false;
    }

    bool ok = false;
    value = text.toDouble(&ok);
    if (ok) {
        return true;
    }

    text.replace(',', '.');
    value = text.toDouble(&ok);
    return ok;
}

QChar detectDelimiter(const QString &line)
{
    const int semicolons = line.count(QLatin1Char(';'));
    const int tabs = line.count(QLatin1Char('\t'));
    const int commas = line.count(QLatin1Char(','));

    if (semicolons >= commas && semicolons >= tabs && semicolons > 0) {
        return QLatin1Char(';');
    }

    if (tabs > commas && tabs > 0) {
        return QLatin1Char('\t');
    }

    return QLatin1Char(',');
}

QStringList splitCsvRow(const QString &line, const QChar delimiter)
{
    QStringList fields;
    QString current;
    bool inQuotes = false;

    for (int index = 0; index < line.size(); ++index) {
        const QChar character = line.at(index);

        if (character == QLatin1Char('"')) {
            if (inQuotes && index + 1 < line.size() && line.at(index + 1) == QLatin1Char('"')) {
                current.append(QLatin1Char('"'));
                ++index;
            } else {
                inQuotes = !inQuotes;
            }
            continue;
        }

        if (character == delimiter && !inQuotes) {
            fields.append(current.trimmed());
            current.clear();
            continue;
        }

        current.append(character);
    }

    fields.append(current.trimmed());
    return fields;
}

QString normalizePath(const QString &source)
{
    const QUrl url(source);
    if (url.isValid() && url.isLocalFile()) {
        return url.toLocalFile();
    }

    return source;
}
} // namespace

AppController::AppController(QObject *parent)
    : QObject(parent)
{
    connect(&m_pointModel, &PointTableModel::countChanged, this, &AppController::pointsChanged);
    connect(&m_pointModel, &QAbstractItemModel::modelReset, this, [this]() {
        emit pointsChanged();
        invalidateResults();
    });
    connect(&m_pointModel, &QAbstractItemModel::dataChanged, this, [this]() {
        emit pointsChanged();
        invalidateResults();
    });
}

PointTableModel *AppController::pointModel()
{
    return &m_pointModel;
}

QString AppController::statusMessage() const
{
    return m_statusMessage;
}

QString AppController::statusTone() const
{
    return m_statusTone;
}

bool AppController::hasPoints() const
{
    return m_pointModel.count() > 0;
}

bool AppController::hasResults() const
{
    return !m_segmentResults.isEmpty();
}

int AppController::pointCount() const
{
    return m_pointModel.count();
}

int AppController::missingYCount() const
{
    int missingValues = 0;
    const QVector<DataPoint> points = m_pointModel.points();
    for (const DataPoint &point : points) {
        if (!point.y.has_value()) {
            ++missingValues;
        }
    }

    return missingValues;
}

QString AppController::summaryText() const
{
    return m_summaryText;
}

QString AppController::plcCode() const
{
    return m_plcCode;
}

QVariantList AppController::segmentResults() const
{
    return m_segmentResults;
}

void AppController::loadCsv(const QString &source)
{
    const QString filePath = normalizePath(source);
    QFile file(filePath);
    if (!file.exists()) {
        setStatus(QStringLiteral("No se encontro el archivo seleccionado."), QStringLiteral("error"));
        return;
    }

    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        setStatus(QStringLiteral("No se pudo abrir el CSV."), QStringLiteral("error"));
        return;
    }

    QTextStream stream(&file);
    QString content = stream.readAll();
    content.remove(QChar(0xFEFF));

    const QStringList rawLines = content.split(QRegularExpression(QStringLiteral("\\r\\n|\\n|\\r")),
                                               Qt::SkipEmptyParts);
    if (rawLines.isEmpty()) {
        setStatus(QStringLiteral("El CSV esta vacio."), QStringLiteral("error"));
        return;
    }

    const QChar delimiter = detectDelimiter(rawLines.first());
    QVector<DataPoint> points;
    points.reserve(rawLines.size());

    bool headerSkipped = false;
    for (int lineIndex = 0; lineIndex < rawLines.size(); ++lineIndex) {
        const QString line = rawLines.at(lineIndex).trimmed();
        if (line.isEmpty()) {
            continue;
        }

        const QStringList fields = splitCsvRow(line, delimiter);
        if (fields.size() < 2) {
            setStatus(QStringLiteral("La fila %1 no tiene al menos dos columnas.")
                          .arg(lineIndex + 1),
                      QStringLiteral("error"));
            return;
        }

        double xValue = 0.0;
        double yValue = 0.0;
        const bool xOk = parseNumber(fields.at(0), xValue);
        const bool yOk = parseNumber(fields.at(1), yValue);

        if (lineIndex == 0 && (!xOk || !yOk) && !headerSkipped) {
            headerSkipped = true;
            continue;
        }

        if (!xOk || !yOk) {
            setStatus(QStringLiteral("La fila %1 contiene valores no numericos en las dos primeras columnas.")
                          .arg(lineIndex + 1),
                      QStringLiteral("error"));
            return;
        }

        points.append({xValue, yValue});
    }

    if (points.isEmpty()) {
        setStatus(QStringLiteral("No se encontraron puntos validos en el CSV."), QStringLiteral("error"));
        return;
    }

    m_pointModel.setPoints(points);
    invalidateResults();

    const QString fileName = QFileInfo(filePath).fileName();
    setStatus(QStringLiteral("CSV cargado: %1 (%2 puntos).").arg(fileName).arg(points.size()),
              QStringLiteral("success"));
}

void AppController::generatePoints(double minimum, double maximum, int intervals)
{
    if (!std::isfinite(minimum) || !std::isfinite(maximum)) {
        setStatus(QStringLiteral("Minimo y maximo deben ser numeros validos."), QStringLiteral("error"));
        return;
    }

    if (maximum <= minimum) {
        setStatus(QStringLiteral("El valor maximo debe ser mayor que el minimo."), QStringLiteral("error"));
        return;
    }

    if (intervals < 1) {
        setStatus(QStringLiteral("La cantidad de intervalos debe ser al menos 1."), QStringLiteral("error"));
        return;
    }

    QVector<DataPoint> points;
    points.reserve(intervals + 1);

    const double step = (maximum - minimum) / static_cast<double>(intervals);
    for (int index = 0; index <= intervals; ++index) {
        const double xValue = index == intervals ? maximum : minimum + step * index;
        points.append({xValue, std::nullopt});
    }

    m_pointModel.setPoints(points);
    invalidateResults();

    setStatus(QStringLiteral("Se generaron %1 puntos entre %2 y %3.")
                  .arg(points.size())
                  .arg(formatNumber(minimum, 4))
                  .arg(formatNumber(maximum, 4)),
              QStringLiteral("success"));
}

void AppController::clearPoints()
{
    m_pointModel.clear();
    invalidateResults();
    setStatus(QStringLiteral("Se limpiaron los puntos actuales."), QStringLiteral("neutral"));
}

void AppController::updatePointY(int row, const QString &value)
{
    QString errorMessage;
    if (!m_pointModel.setYValue(row, value, &errorMessage)) {
        setStatus(errorMessage, QStringLiteral("error"));
        return;
    }

    if (!value.trimmed().isEmpty()) {
        setStatus(QStringLiteral("Valor Y actualizado."), QStringLiteral("neutral"));
    }
}

void AppController::runAnalysis()
{
    if (!hasPoints()) {
        setStatus(QStringLiteral("Primero carga un CSV o genera puntos."), QStringLiteral("error"));
        return;
    }

    const int missingValues = missingYCount();
    if (missingValues > 0) {
        setStatus(QStringLiteral("Faltan %1 valores Y por completar antes del analisis.").arg(missingValues),
                  QStringLiteral("error"));
        return;
    }

    const SegmentFitService::Result result = SegmentFitService::analyze(m_pointModel.points());
    if (!result.errorMessage.isEmpty()) {
        setStatus(result.errorMessage, QStringLiteral("error"));
        return;
    }

    QVariantList segmentItems;
    segmentItems.reserve(result.segments.size());

    for (int index = 0; index < result.segments.size(); ++index) {
        const SegmentResult &segment = result.segments.at(index);
        QVariantMap item;
        item.insert(QStringLiteral("title"), QStringLiteral("Tramo %1").arg(index + 1));
        item.insert(QStringLiteral("range"),
                    QStringLiteral("%1 -> %2")
                        .arg(formatNumber(segment.xStart, 4), formatNumber(segment.xEnd, 4)));
        item.insert(QStringLiteral("equation"),
                    QStringLiteral("OUT = %1 * IN + %2")
                        .arg(formatNumber(segment.slope), formatNumber(segment.intercept)));
        item.insert(QStringLiteral("rsquared"),
                    QStringLiteral("R² = %1").arg(formatNumber(segment.rSquared, 5)));
        segmentItems.append(item);
    }

    m_segmentResults = segmentItems;
    m_plcCode = SegmentFitService::buildPlcCode(result.segments);
    m_summaryText = QStringLiteral("%1 puntos procesados, %2 segmentos, tolerancia abs. %3")
                        .arg(pointCount())
                        .arg(result.segments.size())
                        .arg(formatNumber(result.absoluteTolerance, 6));

    emit resultsChanged();
    setStatus(QStringLiteral("Analisis completado con %1 segmentos.").arg(result.segments.size()),
              QStringLiteral("success"));
}

void AppController::setStatus(const QString &message, const QString &tone)
{
    const bool messageChanged = m_statusMessage != message;
    const bool toneChanged = m_statusTone != tone;

    m_statusMessage = message;
    m_statusTone = tone;

    if (messageChanged || toneChanged) {
        emit statusMessageChanged();
    }
}

void AppController::invalidateResults()
{
    const bool hadResults = !m_segmentResults.isEmpty() || !m_plcCode.isEmpty() || !m_summaryText.isEmpty();

    m_segmentResults.clear();
    m_plcCode.clear();
    m_summaryText.clear();

    if (hadResults) {
        emit resultsChanged();
    }
}
