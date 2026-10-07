# acorn

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


Pipeline: photo → vision model → JSON → confirmation screen → scheduling.

Vision model rather than OCR alone: OCR produces raw text, which would then need to be interpreted (abbreviations like BD, TDS, PRN, variable layout). The model reads and structures the data in a single step.
AI extracts, code decides: `scheduleFor()` converts “twice a day” into specific times. This is predictable and testable, and the model cannot invent times.
“NEVER guess” + uncertain: a flagged empty field is less dangerous than a made-up dosage (5 mg or 50 mg).
Mandatory confirmation: nothing is saved without human validation. This is a security requirement.

Flutter Web: the job requires Flutter, and the web version avoids the need to install an emulator, which was impossible within the allotted time.


Results
Error 404: the gemini-2.5-flash model was removed; fixed by switching to 3.8-flash.
Request remained “pending” for more than 1 min seconds on a 547 Ko photo. Note these figures.

503 error after waiting 4.5 minutes;
I should add a maximum wait time of 15 seconds with a clear message, spaced-out retry attempts, and a backup option or the phone's built-in OCR.

No example labels were provided, so accuracy evaluation is not possible.

# Route Table:
| Route | Feasibility | Key Considerations / Risks |
|---|---|---|
| Label photo | Feasible today | PDPA compliance: consent, health data protection, and potential transfer of images outside Singapore if the API is hosted overseas. |
| HealthHub screenshot | Potentially feasible | The patient transfers their own data, without requiring a partnership. To verify: Does HealthHub actually display the list of medications? |
| Direct NEHR access | Not feasible for a consumer app | The Health Information Act (passed January 12, 2026; scheduled to take effect in early 2027) restricts access to healthcare providers treating the patient. |
| Clinical or pharmacy partnership | Feasible, but complex | The only route to official data. Requires a partnership/contract, takes months to establish, and involves cybersecurity compliance. |
| Voice recognition | Technically easy | Medication names are often transcribed incorrectly. Better suited for corrections than initial data entry. |

I would go for HealthHub screenshot since it is pretty convenient for everyone. But only as the foundation, for private doctor or other medication a screenshot would be better and could be completed by the user very easily only after complying with ppda and the API terms of use.