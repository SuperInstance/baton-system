# Live Paradigm Pipeline API Endpoints

## Core Pipeline Ports
| Port | Service | Description |
|------|---------|-------------|
|  | **OpenSMILE Bridge** | Streaming eGeMAPS feature extraction from microphone input |
|  | **Ghost Track** | T-0..T-4 real-time prediction & confidence monitoring |
|  | **tminus-dispatcher** | Cue scheduling & time-based event routing |
|  | **Fleet Conductor** | Central router for all MIDI/ternary cues to 16 fleet agents |
|  | **16 Fleet-MIDI Agents** | Per-agent ternary logic: chord, scale, voicing, tempo, cc, etc. |
|  | **Piper TTS** | Text-to-speech output with SSML prosody mapping |
|  | **lever-runner HTTP API** | Bot command REST interface

## Fleet-MIDI Agent Port Map
| Port | Agent Role |
|------|------------|
|  | chord |
|  | scale |
|  | voicing |
|  | tempo |
|  | cc |
|  | expression |
|  | dynamics |
|  | pan |
|  | modulation |
|  | arp |
|  | groove |
|  | velocity |
|  | fx |
|  | register |
|  | melody |
|  | bass |

## MIDI Pipeline Workflow
1. Browser microphone → OpenSMILE Bridge
2. → Ghost Track predictions
3. → tminus-dispatcher scheduling
4. → Fleet Conductor routing
5. → Fleet-MIDI Agents for ternary logic
6. → Piper TTS output
