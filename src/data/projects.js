export const projects = [
  {
    slug: 'magazineguessr',
    year: 2026,
    title: 'MagazineGuessr.com',
    subheading: 'Web Game',
    image: 'magazineguessr.png',
    description:
      'Tägliches Ratespiel, bei dem Spieler anhand von Seiten aus Zeitschriften des Internet Archive das Erscheinungsjahr schätzen müssen.',
    links: { live: 'https://magazineguessr.com', github: 'https://github.com/magazine-guesser' },
    goals: `MagazineGuessr ist ein tägliches Ratespiel, bei dem Spieler anhand von Zeitschriftenseiten aus dem Internet Archive das Erscheinungsjahr schätzen. Pro Tag stehen drei Zeitschriften bereit und je nach Schätzung erhählt man einen Score.

Ziel war es, gemeinsam im Team ein Web Game zu entwickeln, das anderen Spaß macht und Spieler dazu einlädt, am nächsten Tag wiederzukehren. Zusätzlich sollten dabei best practices in React, AWS CDK und TypeScript vertieft werden.`,
    requirements: [
      {
        title: 'Copyright Absicherung',
        description: 'Es wird ausschließlich der Identifier einer Zeitschrift gespeichert. Die Zeitschriftenseiten selbst werden im Frontend direkt über die öffentliche API des Internet Archive abgerufen und nie zwischengespeichert oder über eine eigene Schnittstelle weitergereicht. Sollte ein Copyright-Problem auftreten, können sich Rechteinhaber direkt an das Legal Team des Internet Archive wenden, das auf solche Fragen spezialisiert ist.',
      },
      {
        title: 'Inhaltsrichtlinien',
        description: 'Es werden keine Zeitschriften verwendet, deren Inhalte gegen den digitalen Jugendschutz verstoßen.',
      },
      {
        title: 'Wiederholbarkeit',
        description: 'Zeitschriften, die bereits als Daily Challenge erschienen sind, werden für 180 Tage gesperrt und erst danach wieder in den spielbaren Pool aufgenommen.',
      },
      {
        title: 'Inhaltliche und visuelle Qualität',
        description: 'Ausgewählte Zeitschriften müssen anhand ihrer Seiten erkennbare Anhaltspunkte auf ihr Erscheinungsjahr bieten und gleichzeitig visuell ansprechende Inhalte enthalten, die das Spielen interessant machen.',
      },
      {
        title: 'Genre Vielfalt',
        description: 'Der kuratierte Pool soll möglichst verschiedene Zeitschriftentypen abdecken, um eine abwechslungsreiche Spielerfahrung zu gewährleisten.',
      },
    ],
    architectureDiagram: 'magazineguessr2.png',
    softwareSections: [
      {
        text: `Die Infrastruktur ist vollständig mit AWS CDK in TypeScript definiert und in drei Stacks aufgeteilt: CertStack (TLS-Zertifikat-Verwaltung via ACM, muss zwingend in us-east-1 liegen da CloudFront nur dort ausgestellte Zertifikate akzeptiert), InfraStack (CloudFront, S3, DynamoDB, Route 53, GitHub OIDC, ECR) und AppStack (Lambda-Funktionen, API Gateway, EventBridge).

Das Frontend wird aus einem privaten S3-Bucket über CloudFront ausgerollt. Das Backend läuft als Node.js 22 Lambda-Funktion mit Fastify, erreichbar über zwei separate API-Gateway-Endpunkte für prod (api.magazineguessr.com) und dev (api.dev.magazineguessr.com). Beide Umgebungen werden über Lambda-Aliase abgebildet.

Als Datenbank kommen zwei DynamoDB Tabellen zum Einsatz. Gegenüber einer RDS Aurora MySQL-Instanz ist DynamoDB im aktuellen Projektstand deutlich günstiger, da bei geringem Verkehr keine dauerhaft laufende Instanz bezahlt werden muss.`,
      },
      {
        heading: 'Internet Archive',
        text: `Um Inhalte einer Zeitschrift abzurufen, benötigt die öffentliche API des Internet Archive den Identifier der Zeitschrift, die beispielsweise so aussieht:`,
        code: `das-magazin-heft-1-januar-1961`,
        textAfter: `Mit diesem Identifier ruft das Frontend einzelne Seiten direkt vom Internet Archive ab: https://archive.org/download/{identifier}/page/n{seitenindex}_w800.jpg`,
      },
      {
        heading: 'Struktur: magazines-pool',
        text: `In der DynamoDB-Tabelle magazines-pool werden alle kuratierten Zeitschriften als Backlog verwaltet. Ein Eintrag sieht so aus:`,
        code: `{
  "identifier":  "das-magazin-heft-1-januar-1961",
  "uuid":        "e1183620-dd8a-4885-854c-225ebe22b830",
  "title":       "Das Magazin",
  "year":        1961,
  "status":      "BACKLOG",
  "pageRanges":  [[1, 4], [14, 15]],
  "redactions":  [
    { "page": 0, "x": 156, "y": 85, "width": 42, "height": 200 }
  ]
}`,
        textAfter: `identifier ist der Internet-Archive-Schlüssel zum Abrufen der Seiten. uuid dient als Sort Key und sorgt für eine pseudo-zufällige Auswahl durch den Scheduler. Da identifier und uuid zusammen den zusammengesetzten Primärschlüssel bilden, lässt sich dieselbe Zeitschrift mit unterschiedlichen pageRanges, durch das ändern der uuid, in den Pool aufnehmen. pageRanges legt fest, welche Seiten der Zeitschrift im Spiel gezeigt werden. redactions beschreibt rechteckige Bereiche auf bestimmten Seiten, die clientseitig geschwärzt werden, um sichtbare Jahreszahlen zu verdecken (Koordinaten in Pixeln relativ zur angezeigten Bildgröße). status gibt an, ob die Zeitschrift als BACKLOG verfügbar oder als USED gesperrt ist.`,
      },
      {
        heading: 'Backend Lambda',
        text: `Das Herzstück vom Backend ist eine Lambda-Funktion, die Anfragen vom Frontend entgegennimmt und REST-Endpunkte bereitstellt: GET /daily/{datum} gibt die drei Zeitschriften ohne das year-Feld zurück, damit Spieler das Erscheinungsjahr nicht im Netzwerk-Tab einsehen können. POST /daily/{datum}/{nr}/guess nimmt eine Schätzung entgegen und gibt das korrekte Jahr, die Differenz sowie den Score zurück (max(0, 1000 − |Schätzung − Jahr| × 10)). Über den Admin-Endpunkt lassen sich neue Zeitschriften in den Pool eintragen sowie die tägliche Auswahl verwalten.

Das Lambda läuft in einer Node.js 22 und dem Fastify-Framework. Der Einsatz von Fastify ermöglicht es, die Anwendung bei Bedarf ohne größere Anpassungen von AWS Lambda auf einen eigenen VPS umzuziehen.

Falls für ein Datum weniger als drei Zeitschriften in der Datenbank hinterlegt sind, werden fehlende Slots automatisch mit Einträgen aus einer statischen fallback.json aufgefüllt.`,
      },
      {
        heading: 'Zeitschriften hinzufügen',
        text: `Neue Zeitschriften werden über eine interne Admin-Oberfläche im Frontend vorbereitet. Über den gesicherten Endpunkt PUT /admin/pool können Zeitschriften mit Identifier, Titel, Erscheinungsjahr, Seitenbereichen und Schwärzungen in den Pool eingetragen werden. Der Admin-Key wird in AWS Secrets Manager hinterlegt und bei jedem Request serverseitig geprüft.

Beim Hinzufügen wird manuell festgelegt, welche Seiten spielbar sind (pageRanges) und an welchen Stellen Jahreszahlen geschwärzt werden müssen (redactions). Langfristig soll dieser manuelle Prozess durch eine OCR-basierte Erkennung automatisiert werden.`,
      },
      {
        heading: 'Scheduler & Recycler',
        text: `Jede Nacht um 00:00 UTC wird der Scheduler-Worker über EventBridge ausgelöst. Er fragt über einen GSI auf dem status-Feld drei Zeitschriften mit Status BACKLOG aus magazines-pool ab. Die drei Einträge werden auf USED gesetzt und erhalten ein TTL-Attribut mit einem Ablaufdatum 180 Tage in der Zukunft. Anschließend werden sie mit dem morgigen Datum und den Nummern 1–3 in magazines-daily eingetragen.

Wenn das TTL eines Eintrags abläuft und DynamoDB ihn automatisch löscht, wird dieses Ereignis über DynamoDB Streams an den Recycler-Worker weitergeleitet. Dieser erkennt anhand von userIdentity.type === "Service", dass es sich um einen TTL-Löschvorgang handelt, und trägt die Zeitschrift mit einer neuen UUID und dem Status BACKLOG wieder in magazines-pool ein womit sie nach 180 Tagen erneut als Daily Challenge erscheinen kann.`,
      },
    ],
    techStack: [
      { name: 'AWS CDK', role: 'Infrastructure as Code – alle Ressourcen in TypeScript definiert, drei Stacks: Cert, Infra, App' },
      { name: 'AWS Lambda', role: 'Serverless Backend (Node.js 22 / Fastify) mit dev- und prod-Alias; separater Scheduler- und Recycler-Worker' },
      { name: 'AWS API Gateway v2', role: 'HTTP-APIs für prod und dev mit eigenen Custom Domains und Throttling-Konfiguration' },
      { name: 'AWS CloudFront + S3', role: 'SPA-Hosting über privaten S3-Bucket mit Origin Access Control' },
      { name: 'AWS DynamoDB', role: 'Zwei Tabellen: magazines-pool (Backlog) und magazines-daily (Tagesauswahl); TTL-basiertes Recycling' },
      { name: 'AWS EventBridge', role: 'Nightly Trigger (00:00 UTC) für den Scheduler-Worker' },
      { name: 'AWS ECR', role: 'Container Registry für den containerisierten Scheduler-Worker' },
      { name: 'AWS Route 53 + ACM', role: 'DNS-Verwaltung und TLS-Zertifikate für magazineguessr.com und Subdomains' },
      { name: 'GitHub OIDC', role: 'CI/CD-Authentifizierung ohne statische Credentials – vier separate Rollen für Infra, Backend, Frontend und Workers' },
    ],
    webUI: `Die Spieloberfläche ist als React 18 / TypeScript Single-Page Application mit Tailwind CSS umgesetzt. Täglich stehen drei Zeitschriften zur Verfügung. Jede Runde beginnt mit einer eingeschränkten Seitenansicht – der Umschlag ist zunächst verborgen. Mit jeder falschen Schätzung werden weitere Seiten der Zeitschrift freigegeben; nach der letzten Fehleingabe erscheint der Cover als finale Hilfe.

Die Punktzahl pro Runde ergibt sich aus dem Abstand zum tatsächlichen Erscheinungsjahr: max(0, 1000 − |Schätzung − Jahrgang| × 40). Das Tagesmaximum liegt bei 3000 Punkten über drei Runden.

Der Spielfortschritt wird vollständig im localStorage gespeichert. Ein Checkpoint-System stellt sicher, dass unterbrochene Spielsitzungen beim nächsten Besuch wiederhergestellt werden können. Abgeschlossene Tages-Challenges werden ebenfalls persistiert, sodass vergangene Ergebnisse einsehbar bleiben.

Eine Abfrage einer Zeitschriftenseite vom Internet Archive dauert im Schnitt etwa 2,4 Sekunden. Da ein serverseitiges Caching und Weiterreichen der Inhalte die Copyright-Anforderung verletzen würde, musste eine andere Lösung gefunden werden: Alle spielbaren Seiten der ersten Zeitschrift werden direkt beim Klick auf "Play Daily Challenge" im Hintergrund vorgeladen. Die Seiten der beiden weiteren Zeitschriften werden während der Anzeige des jeweiligen Zwischenergebnisses geladen. Die erste Zeitschrift hat dadurch noch eine kurze initiale Ladezeit, die beiden folgenden sind jedoch ohne Wartezeit verfügbar und ermöglichen einen nahtlosen Übergang zwischen den Runden.`,
  },
  {
    slug: 'shaderprogrammierung',
    year: 2024,
    title: 'Shaderprogrammierung',
    subheading: 'GLSL Fragment Shader',
    image: 'shader.jpg',
    description:
      'Eine Sammlung von Shadern: Raytracer mit Box-Intersection und Fresnel-Effekt, stochastischer Raytracer mit Soft Shadows, sowie ein Sphere Tracer mit Signed Distance Functions.',
    links: { live: null, github: null },
    shaders: [
      {
        name: 'Heartbeat',
        file: '/shader/heartbeat.glsl',
        description: 'Sphere Tracer mit Signed Distance Functions: animiertes Oktaeder auf einer Wellenebene.',
        heavy: false,
      },
      {
        name: 'Falling Blocks',
        file: '/shader/falling_blocks.glsl',
        description: 'Raytracer mit Box-Intersection, Fresnel-Effekt und animierten fallenden Blöcken.',
        heavy: true,
      },
      {
        name: 'Soft Shadow Spheres',
        file: '/shader/soft_shadow_spehres_stochastic.glsl',
        description: 'Stochastischer Raytracer mit weichen Schatten (64 Shadow Rays pro Pixel).',
        heavy: true,
      },
      {
        name: 'Pushing Spheres',
        file: '/shader/pushing_spheres.glsl',
        description: 'Sphere Tracer mit Hex-Prism SDFs und animierten Elementen durch boolesche Operatoren.',
        heavy: false,
      },
    ],
    fullDescription: `Im Rahmen der Veranstaltung Shaderprogrammierung entstand eine Sammlung von Fragment Shadern, die verschiedene Rendering-Techniken demonstrieren. Alle Shader sind in GLSL geschrieben und laufen vollständig auf der GPU – ohne CPU-seitige Logik außer der Initialisierung des WebGL-Kontexts und dem Übergeben von Uniforms (Zeit, Auflösung).`,
    shaderTechniques: [
      {
        name: 'Heartbeat',
        description: 'Die Szene besteht aus einem animierten Oktaeder über einer prozeduralen Wellenebene. Jede Geometrie wird durch eine Signed Distance Function beschrieben, die den kürzesten Abstand eines Punktes zur Oberfläche zurückgibt. Der Sphere-Tracer schreitet entlang des Sehstrahls in Schritten vor, deren Größe jeweils dem minimalen SDF-Wert entspricht, bis er auf eine Oberfläche trifft oder den Maximalabstand überschreitet.',
      },
      {
        name: 'Falling Blocks',
        description: 'Klassischer Raytracer mit analytischer Box-Intersection. Trifft ein Strahl auf eine Glasfläche, wird der Anteil von Reflexion und Refraktion winkelabhängig nach der Fresnel-Gleichung berechnet: Bei flachem Einfall überwiegt die Reflexion, bei senkrechtem Einfall dominiert die Transmission. Animierte Blöcke fallen durch die Szene und werfen Reflexionen auf die Grundebene.',
      },
      {
        name: 'Soft Shadow Spheres',
        description: 'Für jeden Pixel werden 64 Schattenstrahlen zu zufälligen Punkten auf der Lichtquelle geworfen. Der Anteil der Strahlen, die die Lichtquelle ungehindert erreichen, bestimmt die Schattenintensität. So entstehen realistische Halbschatten (Penumbra) anstelle harter Schattenkanten. Da Live gerendet benötigt der Shader eine leistungsfähige GPU.',
      },
      {
        name: 'Pushing Spheres',
        description: 'Sphere Tracer, der einfache Grundkörper wie Kugeln und Hex-Prismen über boolesche Operatoren (Union, Subtraktion, Schnittmenge) zu komplexerer Geometrie kombiniert.',
      },
    ],
  },
  // {
  //   slug: 'gravity-jumper',
  //   year: 2023,
  //   title: 'Gravity Jumper',
  //   subheading: 'Cross-Platform Videospiel',
  //   image: 'gravityjumper1.png',
  //   description:
  //     'Cross-Platform Videospiel, in dem man die Gravitationsrichtung wechselt. Entwickelt im Scrum-Verfahren über ein Semester mit Azure DevOps, CI/CD und automatisierten Tests.',
  //   links: { live: null, github: null },
  //   fullDescription: `Gravity Jumper ist ein 2D-Plattformspiel, bei dem der Spieler die Gravitationsrichtung wechseln kann. Das Spiel entstand als Gruppenprojekt im Rahmen einer Lehrveranstaltung und wurde vollständig nach dem Scrum-Framework über sechs Sprints entwickelt.
  //
  // Besonderer Fokus lag auf professioneller Softwareentwicklung: agile Prozesse, kontinuierliche Integration und automatisierte Tests waren fester Bestandteil des Entwicklungsprozesses.`,
  //   architecture: `Das Spiel basiert auf dem MonoGame-Framework und nutzt dessen Game-Loop-Architektur (Update/Draw). Die Spiellogik ist in unabhängige Komponenten aufgeteilt: Physics Engine, Input Handler, Renderer und Game State Manager.
  //
  // Azure DevOps wurde für Versionsverwaltung, Sprint-Planung und die CI/CD-Pipeline verwendet. Bei jedem Commit wurden automatisch Unit-Tests ausgeführt und ein Build erstellt.`,
  //   techStack: [
  //     { name: 'C#', role: 'Programmiersprache' },
  //     { name: 'MonoGame', role: 'Cross-Platform Game Framework' },
  //     { name: 'Azure DevOps', role: 'Versionsverwaltung, Sprint-Planung und CI/CD-Pipeline' },
  //     { name: 'MSTest', role: 'Unit-Testing Framework für automatisierte Tests' },
  //   ],
  // },
  // {
  //   slug: 'esport-event-tracker',
  //   year: 2023,
  //   title: 'Esport Event Tracker',
  //   subheading: 'Android App',
  //   image: 'app2.png',
  //   description:
  //     'Android App, die kommende E-Sport Matches für verschiedene Spiele anzeigt. Unterstützt drei Sprachen: Deutsch, Englisch und Italienisch.',
  //   links: { live: null, github: null },
  //   fullDescription: `Der Esport Event Tracker ist eine native Android App, die bevorstehende E-Sport Matches für verschiedene Titel aggregiert und übersichtlich darstellt (vergleichbar mit einem digitalen Spielplan).
  //
  // Die App unterstützt drei Sprachen (Deutsch, Englisch, Italienisch) und nutzt eine externe API zur Datenbeschaffung.`,
  //   architecture: `Die App folgt einer einfachen Activity-basierten Architektur. Daten werden von einer externen E-Sport API über HTTP-Anfragen geladen und im UI dargestellt. Die Mehrsprachigkeit wird über Android-Ressourcendateien (strings.xml) realisiert.`,
  //   techStack: [
  //     { name: 'Java', role: 'Programmiersprache' },
  //     { name: 'Android SDK', role: 'Native App-Entwicklung' },
  //     { name: 'REST API', role: 'Datenbeschaffung für E-Sport Matches' },
  //     { name: 'Android Localization', role: 'Mehrsprachigkeit (DE, EN, IT)' },
  //   ],
  // },
  // {
  //   slug: 'lol-gadgets',
  //   year: 2023,
  //   title: 'LoL Gadgets Webapp',
  //   subheading: 'Single-Page Application',
  //   image: 'lolgadgets.png',
  //   description:
  //     'Single-Page Webapplication zu League of Legends, die einen zufälligen spielbaren Charakter anzeigt und ein Minispiel zur Verifikation der Spielrunde bietet.',
  //   links: { live: null, github: null },
  //   fullDescription: `Die LoL Gadgets Webapp ist eine Single-Page Application rund um das Spiel League of Legends. Sie ruft über die offizielle Riot Games API Daten zu Champions ab und stellt diese dynamisch dar.
  //
  // Ein integriertes Minispiel erlaubt es Spielern, ihren gespielten Champion nach einer Spielrunde zu verifizieren und Statistiken einzusehen.`,
  //   architecture: `Die Anwendung ist als SPA mit Vue.js umgesetzt. Daten werden direkt im Browser von der Riot Games Data Dragon API und der League of Legends API abgerufen. Die gesamte Logik läuft client-seitig, es gibt kein eigenes Backend.`,
  //   techStack: [
  //     { name: 'Vue.js', role: 'Frontend-Framework für die Single-Page Application' },
  //     { name: 'JavaScript', role: 'Programmiersprache' },
  //     { name: 'Riot Games API', role: 'Datenbeschaffung für Champions und Spielstatistiken' },
  //   ],
  // },
]
