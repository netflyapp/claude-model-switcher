# Instrukcja: Claude Code + GLM + DeepSeek

## Cel

Szybkie przełączanie między 3 trybami Claude Code:

| Komenda | Co robi |
| --- | --- |
| `claude-glm` | Claude Code przez Z.AI API, endpoint Anthropic-compatible |
| `claude-deepseek` | Claude Code przez LiteLLM + DeepSeek API, model DeepSeek Chat |
| `claude-native` | Natywny Claude Pro |

Qwen jest celowo usunięty z tej instrukcji do czasu naprawienia konfiguracji modelu i klucza OpenRouter.

## Wymagania

- macOS lub Linux z `zsh`
- Claude Code: `claude --version`
- Python 3.10+ dla aktualnych wersji LiteLLM
- LiteLLM: `python3 -m pip install litellm`
- klucz Z.AI zapisany w `ZAI_API_KEY`
- klucz DeepSeek zapisany w `DEEPSEEK_API_KEY`

Nie zapisuj prawdziwych kluczy API w repozytorium.

## Pliki do przeniesienia na nowy komputer

Na innym komputerze odtwórz lub skopiuj:

1. fragment `~/.zshrc` z sekcji "Konfiguracja zsh"
2. `~/.litellm/config_deepseek.yaml`
3. opcjonalnie `~/litellm_hooks/strip_thinking.py`

Do repozytorium/GitHuba wrzucaj tylko pliki przykładowe bez sekretów, np. `config_deepseek.example.yaml` i `zshrc-claude-models.example`.

## Instalacja na nowym komputerze

### 1. Zainstaluj Claude Code

```sh
npm install -g @anthropic-ai/claude-code
claude --version
```

### 2. Zainstaluj LiteLLM

Użyj Pythona 3.10 lub nowszego. Python 3.9 powoduje błędy importów w nowszych wersjach LiteLLM.

```sh
python3 -m pip install --upgrade litellm
litellm --version
```

### 3. Ustaw klucze API

Dodaj do `~/.zshrc` albo do osobnego prywatnego pliku ładowanego przez `~/.zshrc`:

```sh
export ZAI_API_KEY="twoj_klucz_zai"
export DEEPSEEK_API_KEY="twoj_klucz_deepseek"
```

### 4. Utwórz konfigurację DeepSeek dla LiteLLM

Utwórz katalog:

```sh
mkdir -p ~/.litellm
```

Utwórz plik `~/.litellm/config_deepseek.yaml`:

```yaml
model_list:
  - model_name: claude-opus
    litellm_params:
      model: deepseek/deepseek-chat
      api_key: os.environ/DEEPSEEK_API_KEY

  - model_name: claude-sonnet
    litellm_params:
      model: deepseek/deepseek-chat
      api_key: os.environ/DEEPSEEK_API_KEY

  - model_name: claude-haiku
    litellm_params:
      model: deepseek/deepseek-chat
      api_key: os.environ/DEEPSEEK_API_KEY

router_settings:
  enable_pre_call_checks: true
```

### 5. Konfiguracja zsh

Wklej na końcu `~/.zshrc`:

```sh
# Claude Code - dzwiek + notyfikacja po zakonczeniu
claude() {
  command claude "$@"
  osascript -e 'display notification "Claude czeka na akceptacje" with title "Claude Code" sound name "Glass"'
}

# GLM przez Z.AI API
claude-glm() {
  if [ -z "$ZAI_API_KEY" ]; then
    echo "Brak ZAI_API_KEY"
    return 1
  fi

  export ANTHROPIC_BASE_URL="https://api.z.ai/api/anthropic"
  export ANTHROPIC_AUTH_TOKEN="$ZAI_API_KEY"
  export ANTHROPIC_DEFAULT_HAIKU_MODEL="glm-5.1"
  export ANTHROPIC_DEFAULT_SONNET_MODEL="glm-5-turbo"
  export ANTHROPIC_DEFAULT_OPUS_MODEL="glm-5.1"

  echo "Tryb GLM aktywowany"
  claude "$@"
}

# DeepSeek Chat przez LiteLLM + DeepSeek API
claude-deepseek() {
  if [ -z "$DEEPSEEK_API_KEY" ]; then
    echo "Brak DEEPSEEK_API_KEY"
    return 1
  fi

  pgrep -f "litellm.*config_deepseek" > /dev/null || (
    nohup "$LITELLM_BIN" --config ~/.litellm/config_deepseek.yaml --port 4002 > /tmp/litellm_deepseek.log 2>&1 &
    sleep 5
  )

  export ANTHROPIC_BASE_URL="http://localhost:4002"
  export ANTHROPIC_AUTH_TOKEN="sk-local-deepseek"
  unset ANTHROPIC_DEFAULT_HAIKU_MODEL
  unset ANTHROPIC_DEFAULT_SONNET_MODEL
  unset ANTHROPIC_DEFAULT_OPUS_MODEL

  echo "Tryb DeepSeek aktywowany"
  claude "$@"
}

# Natywny Claude Pro
claude-native() {
  unset ANTHROPIC_BASE_URL
  unset ANTHROPIC_AUTH_TOKEN
  unset ANTHROPIC_DEFAULT_HAIKU_MODEL
  unset ANTHROPIC_DEFAULT_SONNET_MODEL
  unset ANTHROPIC_DEFAULT_OPUS_MODEL

  echo "Tryb natywny Claude aktywowany"
  claude "$@"
}
```

Odśwież terminal:

```sh
source ~/.zshrc
```

## Użycie

```sh
claude-glm
claude-deepseek
claude-native
```

Można dodać argumenty Claude Code, np.:

```sh
claude-glm --dangerously-skip-permissions
```

## Weryfikacja

### GLM

```sh
claude-glm
```

W Claude Code wpisz:

```text
/status
```

Oczekiwany wynik:

```text
Base URL: https://api.z.ai/api/anthropic
```

### DeepSeek

Najpierw sprawdź proxy:

```sh
litellm --config ~/.litellm/config_deepseek.yaml --port 4002
```

W drugim terminalu:

```sh
curl http://localhost:4002/health
```

Oczekiwany wynik zawiera:

```json
"healthy_count": 3
```

Jeśli widzisz `401`, problem jest w `DEEPSEEK_API_KEY`. Jeśli widzisz `connection refused`, LiteLLM nie wystartował albo port jest zajęty.

Potem uruchom:

```sh
claude-deepseek
```

W Claude Code wpisz:

```text
/status
```

Oczekiwany wynik:

```text
Base URL: http://localhost:4002
```

### Native

```sh
claude-native
```

W Claude Code wpisz:

```text
/status
```

Oczekiwany wynik:

```text
Claude Pro Account
```

## Najczęstsze problemy

| Problem | Rozwiązanie |
| --- | --- |
| Aliasy nie działają | Uruchom `source ~/.zshrc` albo otwórz nowe okno terminala |
| `Brak ZAI_API_KEY` | Ustaw `export ZAI_API_KEY="..."` |
| `Brak DEEPSEEK_API_KEY` | Ustaw `export DEEPSEEK_API_KEY="..."` |
| DeepSeek zwraca `401` | Wygeneruj nowy klucz DeepSeek i sprawdź, czy jest aktywny |
| `connection refused` | Sprawdź log `/tmp/litellm_deepseek.log` |
| Port 4002 zajęty | Uruchom `lsof -nP -iTCP:4002 -sTCP:LISTEN`, potem zatrzymaj stary proces |
| LiteLLM rzuca błędy typów na Pythonie 3.9 | Użyj Pythona 3.10+ |

## Status konfiguracji

- `claude-glm`: konfiguracja poprawna, wymaga aktywnego `ZAI_API_KEY`
- `claude-deepseek`: konfiguracja poprawna, wymaga aktywnego `DEEPSEEK_API_KEY`
- `claude-native`: konfiguracja poprawna
- `claude-qwen`: usunięte tymczasowo
