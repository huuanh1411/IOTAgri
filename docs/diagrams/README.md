# Diagram Library

[Documentation index](../README.md)

| Content | View | Editable source |
| --- | --- | --- |
| Context Diagram | [System context and data flows](context-diagram.md) | [Mermaid](system-context.mmd) / [SVG](rendered/context-diagram-radial.svg) |
| Use Case | [Diagram and detailed flows](../use-cases/README.md) | [PlantUML overview](use-case-overview.puml) / [Detailed PlantUML](use-case.puml) |
| ERD | [Overview and data dictionary](../data/README.md) | [Full Mermaid source](erd.mmd) |
| Context, Use Case and ERD on one page | [Combined diagram view](project-diagrams.md) | Context/Use Case SVGs and Mermaid ERD |

The use case diagrams use PlantUML sources and SVG images. All actors are stick figures outside a single shared IOTAgri system boundary, with names below them. Use cases are staggered inside the boundary and connected directly to their actors. Markdown pages embed the SVGs to preserve this layout. The ERD uses Mermaid. The detailed ERD is wide; start with the overview on the data page.

Baseline: **27 October 2026**. See [sources and limitations](../reference/source-baseline.md). Existing `docs/diagrams/*` paths are retained to preserve bookmarks. Supporting explanations are organized by business flows, data and requirements.

## Rendered SVGs

[Use Case overview](rendered/use-case-overview.svg) / [Detailed Use Case](rendered/use-case.svg) / [Detailed ERD](rendered/erd.svg) / [ERD overview](rendered/erd-overview.svg) / [System context](rendered/context-diagram-radial.svg)

SVGs preserve text and lines when zoomed. The two PlantUML files are the editable use case sources; the previous Mermaid flowcharts were replaced to use proper actor notation. After changing the sources, run from the repository root:

```sh
python docs/diagrams/render-use-cases.py
```

The Context Diagram uses a radial layout, with five entities evenly spaced around IOTAgri and concise flow labels. After editing the [Mermaid source](system-context.mmd), preserve this layout by running:

```sh
python docs/diagrams/render-context.py
```

The scripts use only the Python standard library. The use case renderer reads actor, rectangle and use case declarations and associations from the two PlantUML files. It generates an overview and a detailed diagram, each containing all five actors and one system boundary. SVG associations are straight lines from an actor's hand to each use case ellipse, without intermediate routing points. Other PlantUML engines may produce a different layout.

Each use case diagram contains exactly one IOTAgri boundary. All actors are outside it and all use cases are inside. A shared use case is drawn once and linked to every relevant actor. Yellow indicates local/mock functionality. After editing the Mermaid ERD, regenerate its corresponding SVG.
