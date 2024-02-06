# Cloud-Transcription-Service

The core functionality of [Ton-Texter](https://ton-texter.de) is to transcribe audio and video files. Therefore we use models based on OpenAIs [Whisper](https://github.com/openai/whisper). Additionally we perform a speaker diarization with [Pyannote](https://huggingface.co/pyannote). That way we can deliver state of the art transcription performance.

This repository represents the setup of our AWS Cloud infrastructure via Terraform. The following chart gives an overview over our complete application architecture:

![Architecture Overview](https://private-user-images.githubusercontent.com/88674835/302731311-79f0716b-dab0-4abb-b9ba-90626a670a2f.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MDcyNDI3NTMsIm5iZiI6MTcwNzI0MjQ1MywicGF0aCI6Ii84ODY3NDgzNS8zMDI3MzEzMTEtNzlmMDcxNmItZGFiMC00YWJiLWI5YmEtOTA2MjZhNjcwYTJmLnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNDAyMDYlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjQwMjA2VDE4MDA1M1omWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPTllOWVhODk2MzRhYjg1ZjA5MmJmMWU4Y2NmMTA4MjE3NDZjYmVkMzYzMTg5Zjk0OTM0YTlkMGQ3NDVjYmE0NjkmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0JmFjdG9yX2lkPTAma2V5X2lkPTAmcmVwb19pZD0wIn0.YF7NulcYRyc40H7F0IkDyYptMZiopl2EOMXiM8d3CyU)

The transcription application that the EC2 uses for the transcription can be found in the Repository: [Transcription-Application](https://github.com/ns144/Transcription-Application). The related NEXT.js in the Repository: [Ton-Texter](https://github.com/hanneskoksch/ton-texter).

This repository is used to setup the following components:

![AWS Overview](https://private-user-images.githubusercontent.com/88674835/302731318-9c6db8a3-6c28-48a5-a6f8-0b6f0a8b94cd.png?jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3MDcyNDI4NjYsIm5iZiI6MTcwNzI0MjU2NiwicGF0aCI6Ii84ODY3NDgzNS8zMDI3MzEzMTgtOWM2ZGI4YTMtNmMyOC00OGE1LWE2ZjgtMGI2ZjBhOGI5NGNkLnBuZz9YLUFtei1BbGdvcml0aG09QVdTNC1ITUFDLVNIQTI1NiZYLUFtei1DcmVkZW50aWFsPUFLSUFWQ09EWUxTQTUzUFFLNFpBJTJGMjAyNDAyMDYlMkZ1cy1lYXN0LTElMkZzMyUyRmF3czRfcmVxdWVzdCZYLUFtei1EYXRlPTIwMjQwMjA2VDE4MDI0NlomWC1BbXotRXhwaXJlcz0zMDAmWC1BbXotU2lnbmF0dXJlPTJhZTJmOTZlMjc2OWI0ZjNlZjkxOWZlMzA5MGZkNGYzNGQxYjhhOTcyODA4YTM1ZmI5OTZjNjk5NzdiNzMwYjEmWC1BbXotU2lnbmVkSGVhZGVycz1ob3N0JmFjdG9yX2lkPTAma2V5X2lkPTAmcmVwb19pZD0wIn0.rVV8wfkphPdD5306LJiDzQuo2MYBWH45SDTeBuE9mZc)

## Participants

| Name            | Abbreviation |
| --------------- | ------------ |
| Hannes Koksch   | hk058        |
| Nikolas Schaber | ns144        |
| Torben Ziegler  | tz023        |

## Usage

If you want to test our application, proceed as follows:

1. Visit the [Ton-Texter](https://ton-texter.de) application in your browser.

2. Create an account with invitation key "cct2024".

3. Go to "Dashboard".

4. Click on the "Datei hochladen" button to select and upload your audio file.

5. Wait for the transcription process to complete.

6. Download your transcriptions in DOCX, SRT, and TXT formats.

## Related repositories

- [Transcription-Application](https://github.com/ns144/Transcription-Application)
- [Ton-Texter](https://github.com/hanneskoksch/ton-texter)