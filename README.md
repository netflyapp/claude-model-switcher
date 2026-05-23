# Claude Model Switcher

Switch Claude Code between multiple AI providers with a single shell command.

| Command | Provider |
| --- | --- |
| `claude-glm` | GLM via Z.AI API (Anthropic-compatible) |
| `claude-deepseek` | DeepSeek Chat via LiteLLM proxy |
| `claude-native` | Native Claude Pro subscription |

## How it works

Shell functions override `ANTHROPIC_BASE_URL` and `ANTHROPIC_AUTH_TOKEN` environment variables before launching Claude Code. DeepSeek mode additionally starts a local LiteLLM proxy that translates Anthropic API calls to DeepSeek's API.

## Requirements

- macOS or Linux with zsh
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (`npm install -g @anthropic-ai/claude-code`)
- Python 3.10+ (for LiteLLM)
- API keys: Z.AI and/or DeepSeek

## Installation

### 1. Clone and set up virtual environment

```sh
git clone https://github.com/miloszzajac/claude-model-switcher.git
cd claude-model-switcher
python3 -m venv .venv
source .venv/bin/activate
pip install litellm
```

### 2. Configure API keys

```sh
cp .env.example .env
```

Edit `.env` and add your real API keys:

```
ZAI_API_KEY=sk-...
DEEPSEEK_API_KEY=sk-...
```

### 3. Set up LiteLLM config

```sh
mkdir -p ~/.litellm
cp config_deepseek.example.yaml ~/.litellm/config_deepseek.yaml
```

### 4. Add shell functions to ~/.zshrc

```sh
cp zshrc-claude-models.example ~/.zshrc-claude-models
```

Edit `~/.zshrc-claude-models` and set `CLAUDE_MODELS_DIR` to the cloned repo path.

Add to `~/.zshrc`:

```sh
[ -f ~/.zshrc-claude-models ] && source ~/.zshrc-claude-models
```

Reload:

```sh
source ~/.zshrc
```

### 5. (Optional) Auto-start LiteLLM proxy on login

```sh
# Edit the example plist, replace REPLACE_WITH_FULL_PATH_TO with the actual path
cp com.milosz.claude-deepseek.example.plist ~/Library/LaunchAgents/com.milosz.claude-deepseek.plist
launchctl load ~/Library/LaunchAgents/com.milosz.claude-deepseek.plist
```

## Usage

```sh
claude-glm          # GLM via Z.AI
claude-deepseek     # DeepSeek Chat
claude-native       # Back to native Claude Pro
```

Pass any Claude Code arguments:

```sh
claude-glm --dangerously-skip-permissions
```

## Verification

Inside Claude Code, type `/status` to see the active provider:

- `claude-glm` → Base URL: `https://api.z.ai/api/anthropic`
- `claude-deepseek` → Base URL: `http://localhost:4002`
- `claude-native` → Claude Pro Account

## Troubleshooting

| Problem | Solution |
| --- | --- |
| Aliases not working | Run `source ~/.zshrc` or open a new terminal |
| `Missing ZAI_API_KEY` | Set in `.env` and ensure `~/.zshrc-claude-models` sources it |
| `Missing DEEPSEEK_API_KEY` | Same as above |
| DeepSeek returns `401` | Regenerate API key at platform.deepseek.com |
| `connection refused` | Check `/tmp/litellm_deepseek.log` |
| Port 4002 busy | `lsof -nP -iTCP:4002 -sTCP:LISTEN` then kill the process |
| LiteLLM import errors on Python 3.9 | Upgrade to Python 3.10+ |

## Project structure

```
.env.example                          # API key placeholders
.gitignore
config_deepseek.example.yaml          # LiteLLM config template
com.milosz.claude-deepseek.example.plist  # macOS LaunchAgent template
start-litellm-deepseek.sh             # LiteLLM proxy launcher
zshrc-claude-models.example           # Shell functions template
```

## License

[MIT](LICENSE)
