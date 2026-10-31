# Context Diagram - IOTAgri System Context

[Diagram library](README.md) / [SRS](../requirements/SRS.md) / [Use Case](../use-cases/README.md) / [All diagrams](project-diagrams.md)

The context diagram represents IOTAgri as **one process** exchanging data with five external entities evenly distributed around the central circle. Arrows indicate data-flow direction. Labels are concise; the table below provides details. The diagram follows the **27 October 2026** baseline in the [SRS](../requirements/SRS.md) and [source reference](../reference/source-baseline.md).

![Context Diagram - IOTAgri and External Entities](rendered/context-diagram-radial.svg)

[Open SVG](rendered/context-diagram-radial.svg) / [Mermaid source](system-context.mmd)

## System boundary

IOTAgri includes the Flutter application, ASP.NET Core backend, scheduling and alert processing, PostgreSQL database, and the system's MQTT/Mosquitto infrastructure. These components are internal to IOTAgri and are not shown as external entities. ESP32 is an external device exchanging data with IOTAgri. SMTP is an external email delivery service.

At the context level, the ESP32 connection combines two channels: pairing through the HTTP API and exchanging readings, commands and status through MQTT. See the technical connection flow in [SRS section 2.2](../requirements/SRS.md) for the intermediate components.

## Data flows

| External entity | Data sent to IOTAgri | Data sent by IOTAgri |
| --- | --- | --- |
| Guest | Registration/sign-in details; password recovery requests and password reset data | Authentication results, sessions and password request results |
| Authenticated user | Device management and monitoring requests; pump/light commands; schedules, thresholds and support tickets | Readings, history and device status; command results, alerts and support responses |
| Administrator | Account/device administration requests; configuration, report queries and support actions | Administration data, reports/CSV, audit logs, status and operation results |
| ESP32 device | Pairing code, hardwareId; sensor readings, ACKs and pump/light status | DeviceKey, MQTT configuration/credentials and pump/light control commands |
| SMTP email service | No incoming business data flow from SMTP is shown | Email delivery requests, recipient addresses and password reset links |

SMTP delivers messages to recipient mailboxes according to its configuration. The diagram does not assume a delivery confirmation callback. Alerts represent data users can view within the system; they do not imply an implemented cloud push notification service. Sending a command does not prove that the relay executed it: device ACKs and status are separate response flows.

## Updating the diagram

Edit [system-context.mmd](system-context.mmd), then regenerate the SVG from the repository root:

```sh
python docs/diagrams/render-context.py
```

The script uses the Python standard library. It reads entity names and flow labels from the Mermaid source and positions five entities at 72-degree intervals around the circle. Rendering directly with Mermaid may produce a different layout.

The context diagram shows the system boundary and data flows. The [Use Case](../use-cases/README.md) documentation describes actor goals, while the [ERD](../data/README.md) describes the data structure.
