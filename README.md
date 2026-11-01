# Range ta vie d’étudiant

Site responsive en français pour la formation en ligne « Range ta vie d’étudiant ». Le projet utilise HTML, CSS et JavaScript natifs : aucun outil de compilation ni dépendance à installer.

## Site en ligne

Le site est accessible depuis tout appareil à l’adresse [https://simedolvich-10.github.io/range-ta-vie-etudiant/](https://simedolvich-10.github.io/range-ta-vie-etudiant/). Les vidéos sont hébergées avec le site et sont publiques.

## Ouvrir le site

Double-clique sur `Ouvrir le site.bat` sur Windows. Il démarre le serveur vidéo en arrière-plan puis ouvre directement `http://127.0.0.1:8765/modules.html`. La fenêtre du serveur reste masquée ; il n’est pas nécessaire de la garder ouverte. Le raccourci utilise le chemin du dossier où il se trouve, même si le dossier est déplacé. Aucune installation n’est nécessaire. Une connexion Internet est requise pour ouvrir Classroom et Google Forms.

Les liens entre les pages fonctionnent directement. La navigation mobile fonctionne sans compte. Le cours est hébergé sur Google Classroom et le quiz sur Google Forms ; une connexion Google peut être demandée selon les réglages de ces services.

## Cours et quiz

- Cours Classroom : [rejoindre la classe](https://classroom.google.com/c/ODI2ODAyNjIyODg0?cjc=izhsfn7n), code `izhsfn7n`.
- Quiz officiel : [ouvrir le questionnaire Google Forms](https://docs.google.com/forms/d/e/1FAIpQLSeabF2TVk_FQI3DPZJOstu6in3TQPsbHOI-p7lxRyKmaJV_Jw/viewform?usp=dialog).

Les ressources du cours et les questions du quiz restent gérées dans leurs espaces Google d’origine. Le site fournit des liens directs plutôt que de recopier leur contenu.

Les dix vidéos fournies sont copiées dans `assets/videos/` et affichées dans cet ordre sur la page « Le cours ». Elles sont servies en HTTP local avec prise en charge des requêtes par plages d’octets, nécessaire à la lecture et à la navigation dans les vidéos. Utilise le raccourci de démarrage : ouvrir directement la page par son chemin `file://` ne permet pas de lire les vidéos.

| Ordre | Fichier du site | Fichier source |
|---:|---|---|
| 1 | `video-01.mp4` | `WhatsApp Video 2026-10-28 at 2.48.28 PM.mp4` |
| 2 | `video-02.mp4` | `WhatsApp Video 2026-10-28 at 2.47.24 PM (1).mp4` |
| 3 | `video-03.mp4` | `WhatsApp Video 2026-10-28 at 2.48.56 PM.mp4` |
| 4 | `video-04.mp4` | `WhatsApp Video 2026-10-28 at 2.44.47 PM.mp4` |
| 5 | `video-05.mp4` | `WhatsApp Video 2026-10-28 at 2.45.07 PM.mp4` |
| 6 | `video-06.mp4` | `WhatsApp Video 2026-10-29 at 3.36.30 PM.mp4` |
| 7 | `video-07.mp4` | `WhatsApp Video 2026-10-28 at 2.46.17 PM.mp4` |
| 8 | `video-08.mp4` | `WhatsApp Video 2026-10-28 at 2.45.54 PM.mp4` |
| 9 | `video-09.mp4` | `WhatsApp Video 2026-10-29 at 3.32.04 PM.mp4` |
| 10 | `video-10.mp4` | `WhatsApp Video 2026-10-28 at 2.48.04 PM.mp4` |

Les fichiers source des vidéos 1 et 3 avaient la même date et heure mais étaient absents avec le suffixe `(1)` ; les versions sans ce suffixe ont été utilisées après confirmation.

Les vidéos utilisent le lecteur intégré au navigateur et sont chargées à la demande. Les illustrations locales sont rangées dans `assets/images/`.

## Arborescence

```text
range-ta-vie-etudiant/
├── index.html
├── modules.html
├── quiz.html
├── a-propos.html
├── Ouvrir le site.bat
├── serve-site.ps1
├── README.md
├── css/
│   └── style.css
├── js/
│   └── main.js
└── assets/
    ├── images/
    ├── videos/
    │   ├── video-01.mp4 à video-10.mp4
    └── icons/
```
