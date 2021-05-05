# twilio_programmable_voice

Non-official Flutter Twilio API for Twilio Programmable Voice Resource

## Structure :

- backend: `/server` (NestJS for testing purpose)

## TODOS : 
- Re-implement callkeep in the example to handle calls. For now, we're able to receive TwilioEvent on the dart side. But we have no link to the Telecom Manager (Android only). And we do want to receive the call notification from Telecom manager, because it's cleaner this way. So basically, what we have to do is to :
    - Ask the authorization from the user to use Telecom Manager
    - Setup the telecom manager service
    - Bind call invites to the telecom service
    - Start call via telecom manager (like iOS does)
    - ... ?