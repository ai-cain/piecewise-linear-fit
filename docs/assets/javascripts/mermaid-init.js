document.addEventListener("DOMContentLoaded", async function () {
    if (typeof mermaid === "undefined") {
        return;
    }

    mermaid.initialize({
        startOnLoad: false,
        securityLevel: "loose",
        theme: "default"
    });

    const nodes = Array.from(document.querySelectorAll(".mermaid"));
    if (nodes.length === 0) {
        return;
    }

    try {
        await mermaid.run({ nodes: nodes });
    } catch (error) {
        console.error("Mermaid rendering failed:", error);
    }
});
