export const projects = [
  {
    slug: 'magazineguessr',
    year: 2026,
    title: 'MagazineGuessr.com',
    subheading: 'Web Game',
    image: 'magazineguessr.png',
    description:
      'Ratespiel mit täglich neuen Inhalten, bei dem Spieler anhand von Seiten aus Magazinen das Erscheinungsjahr schätzen müssen.',
    tags: ['AWS CDK', 'Serverless', 'TypeScript', 'Node.js'],
    links: { live: 'https://magazineguessr.com', github: null },
    fullDescription: `MagazineGuessr ist ein Ratespiel, bei dem täglich neue Magazine bereitgestellt werden. Spieler müssen anhand visueller Hinweisen das Erscheinungsjahr der jeweiligen Seite schätzen.

Ein automatisierter Prozess stellt jeden Tag neue Inhalte bereit, sodass Spieler täglich zurückkehren können.`,
    architecture: `Die Infrastruktur ist vollständig mit AWS CDK definiert.

Das Frontend wird aus einem privaten S3-Bucket über CloudFront mit Origin Access Control (OAC) ausgeliefert. Das Backend läuft als Node.js 22 Lambda-Funktion, die als REST-API via HTTP Gateway erreichbar ist, mit zwei Aliasen: dev (latest) und prod (stabile Version).

Zwei DynamoDB-Tabellen bilden die Datenbasis: magazines-daily für die tägliche Auswahl und magazines-pool als Katalog aller verfügbaren Magazine. Das CI/CD-Setup nutzt GitHub OIDC, sodass keine statischen AWS-Credentials gespeichert werden müssen.

Die eigentlichen Magazinseiten werden nicht im Backend gespeichert. Stattdessen werden pro Eintrag nur der Identifier des Magazins, das Erscheinungsjahr, sowie Markierungen für die Zensur von Jahreszahlen hinterlegt. Die Bilder selbst werden zur Laufzeit direkt vom Internet Archive (archive.org) bezogen.`,
    techStack: [
      { name: 'AWS CDK', role: 'Infrastructure as Code, Stacks in TypeScript definiert' },
      { name: 'AWS Lambda', role: 'Serverless Backend, als REST-API via HTTP Gateway erreichbar, mit dev- und prod-Alias' },
      { name: 'AWS API Gateway v2', role: 'HTTP-APIs für prod und dev mit separaten Throttling-Limits für öffentliche und Admin-Routen' },
      { name: 'AWS CloudFront', role: 'CDN mit Origin Access Control auf privaten S3 bucket' },
      { name: 'AWS S3', role: 'Privater bucket mit Frontend-Assets und Deployment' },
      { name: 'AWS DynamoDB', role: 'Zwei On-Demand-Tabellen: magazines-daily (tägliche Auswahl) und magazines-pool (vorbereitete spielbare Zeitschriften)' },
      { name: 'AWS ECR', role: 'Container Registry für scheduled Image, welches aus magazines-pool die tägliche Auswahl bildet' },
      { name: 'AWS Route 53', role: 'DNS-Verwaltung für magazineguessr.com und Subdomains' },
      { name: 'GitHub OIDC', role: 'CI/CD mit minimal berechtigten IAM-Rollen' },
      { name: 'TypeScript', role: 'Sprache die im Front- und Backend hauptsächlich genutzt wird' },
    ],
  },
  {
    slug: 'shaderprogrammierung',
    year: 2024,
    title: 'Shaderprogrammierung',
    subheading: 'GLSL Fragment Shader',
    image: 'shader.jpg',
    description:
      'Eine Sammlung von Shadern: Raytracer mit Box-Intersection und Fresnel-Effekt, stochastischer Raytracer mit Soft Shadows, sowie ein Sphere Tracer mit Signed Distance Functions.',
    tags: ['GLSL', 'WebGL', 'Raytracing'],
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
    fullDescription: `Im Rahmen der Veranstaltung Shaderprogrammierung entstand eine Sammlung von Fragment Shadern, die verschiedene Rendering-Techniken demonstrieren. Alle Shader sind in GLSL geschrieben und laufen direkt auf der GPU.

Die Projekte reichen von klassischem Raytracing über stochastische Methoden bis hin zu modernen Signed Distance Function Techniken.`,
    architecture: `Alle Shader sind als GLSL Fragment Shader implementiert und werden vollständig auf der GPU ausgeführt. Es gibt keine CPU-seitige Logik außer der Initialisierung des WebGL-Kontexts und dem Übergeben von Uniforms (Zeit, Auflösung).

Jeder Shader berechnet pro Fragment (Pixel) eigenständig Farbe und Beleuchtung durch mathematische Strahlverfolgung.`,
    techStack: [
      { name: 'GLSL', role: 'Shader-Sprache für alle Fragment-Programme' },
      { name: 'WebGL', role: 'Browser-API zur GPU-Ausführung der Shader' },
      { name: 'Raytracing', role: 'Rendering-Technik für realistische Beleuchtung, inklusive reflektierter und gebrochener Strahlen zur Simulation von bspw. der Transparenz von Glas oder der Spiegelung von polierten Oberflächen.' },
      { name: 'Signed Distance Functions', role: 'Mathematische Beschreibung von 3D-Geometrie für den Sphere Tracer' },
    ],
  },
  {
    slug: 'gravity-jumper',
    year: 2023,
    title: 'Gravity Jumper',
    subheading: 'Cross-Platform Videospiel',
    image: 'gravityjumper1.png',
    description:
      'Cross-Platform Videospiel, in dem man die Gravitationsrichtung wechselt. Entwickelt im Scrum-Verfahren über ein Semester mit Azure DevOps, CI/CD und automatisierten Tests.',
    tags: ['C#', 'MonoGame', 'Scrum', 'Azure DevOps'],
    links: { live: null, github: null },
    fullDescription: `Gravity Jumper ist ein 2D-Plattformspiel, bei dem der Spieler die Gravitationsrichtung wechseln kann. Das Spiel entstand als Gruppenprojekt im Rahmen einer Lehrveranstaltung und wurde vollständig nach dem Scrum-Framework über sechs Sprints entwickelt.

Besonderer Fokus lag auf professioneller Softwareentwicklung: agile Prozesse, kontinuierliche Integration und automatisierte Tests waren fester Bestandteil des Entwicklungsprozesses.`,
    architecture: `Das Spiel basiert auf dem MonoGame-Framework und nutzt dessen Game-Loop-Architektur (Update/Draw). Die Spiellogik ist in unabhängige Komponenten aufgeteilt: Physics Engine, Input Handler, Renderer und Game State Manager.

Azure DevOps wurde für Versionsverwaltung, Sprint-Planung und die CI/CD-Pipeline verwendet. Bei jedem Commit wurden automatisch Unit-Tests ausgeführt und ein Build erstellt.`,
    techStack: [
      { name: 'C#', role: 'Programmiersprache' },
      { name: 'MonoGame', role: 'Cross-Platform Game Framework' },
      { name: 'Azure DevOps', role: 'Versionsverwaltung, Sprint-Planung und CI/CD-Pipeline' },
      { name: 'MSTest', role: 'Unit-Testing Framework für automatisierte Tests' },
    ],
  },
  {
    slug: 'esport-event-tracker',
    year: 2023,
    title: 'Esport Event Tracker',
    subheading: 'Android App',
    image: 'app2.png',
    description:
      'Android App, die kommende E-Sport Matches für verschiedene Spiele anzeigt. Unterstützt drei Sprachen: Deutsch, Englisch und Italienisch.',
    tags: ['Android', 'Java'],
    links: { live: null, github: null },
    fullDescription: `Der Esport Event Tracker ist eine native Android App, die bevorstehende E-Sport Matches für verschiedene Titel aggregiert und übersichtlich darstellt (vergleichbar mit einem digitalen Spielplan).

Die App unterstützt drei Sprachen (Deutsch, Englisch, Italienisch) und nutzt eine externe API zur Datenbeschaffung.`,
    architecture: `Die App folgt einer einfachen Activity-basierten Architektur. Daten werden von einer externen E-Sport API über HTTP-Anfragen geladen und im UI dargestellt. Die Mehrsprachigkeit wird über Android-Ressourcendateien (strings.xml) realisiert.`,
    techStack: [
      { name: 'Java', role: 'Programmiersprache' },
      { name: 'Android SDK', role: 'Native App-Entwicklung' },
      { name: 'REST API', role: 'Datenbeschaffung für E-Sport Matches' },
      { name: 'Android Localization', role: 'Mehrsprachigkeit (DE, EN, IT)' },
    ],
  },
  {
    slug: 'lol-gadgets',
    year: 2023,
    title: 'LoL Gadgets Webapp',
    subheading: 'Single-Page Application',
    image: 'lolgadgets.png',
    description:
      'Single-Page Webapplication zu League of Legends, die einen zufälligen spielbaren Charakter anzeigt und ein Minispiel zur Verifikation der Spielrunde bietet.',
    tags: ['JavaScript', 'Vue.js'],
    links: { live: null, github: null },
    fullDescription: `Die LoL Gadgets Webapp ist eine Single-Page Application rund um das Spiel League of Legends. Sie ruft über die offizielle Riot Games API Daten zu Champions ab und stellt diese dynamisch dar.

Ein integriertes Minispiel erlaubt es Spielern, ihren gespielten Champion nach einer Spielrunde zu verifizieren und Statistiken einzusehen.`,
    architecture: `Die Anwendung ist als SPA mit Vue.js umgesetzt. Daten werden direkt im Browser von der Riot Games Data Dragon API und der League of Legends API abgerufen. Die gesamte Logik läuft client-seitig, es gibt kein eigenes Backend.`,
    techStack: [
      { name: 'Vue.js', role: 'Frontend-Framework für die Single-Page Application' },
      { name: 'JavaScript', role: 'Programmiersprache' },
      { name: 'Riot Games API', role: 'Datenbeschaffung für Champions und Spielstatistiken' },
    ],
  },
]
