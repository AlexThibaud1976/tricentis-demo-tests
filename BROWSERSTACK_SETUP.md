# Configuration BrowserStack pour Playwright

## Prérequis

1. Créer un compte sur [BrowserStack](https://www.browserstack.com/)
2. Obtenir vos identifiants depuis [Automate Dashboard](https://automate.browserstack.com/)

## Configuration GitHub Actions

### 1. Ajouter les secrets GitHub

Dans votre repository GitHub, allez dans **Settings** > **Secrets and variables** > **Actions** > **New repository secret**

Ajoutez les deux secrets suivants :
- `BROWSERSTACK_USERNAME` : Votre nom d'utilisateur BrowserStack
- `BROWSERSTACK_ACCESS_KEY` : Votre clé d'accès BrowserStack

### 2. Lancer les tests

Les tests BrowserStack se lancent automatiquement en parallèle des tests locaux à chaque push/PR.

Le job `test-browserstack` exécutera tous les tests en séquentiel (workers=1) sur :
- **Navigateur** : Chrome (dernière version)
- **OS** : Windows 11
- **Mode** : Headless

## Tester localement avec BrowserStack

### 1. Configurer les variables d'environnement

**Windows PowerShell :**
```powershell
$env:BROWSERSTACK_USERNAME="votre_username"
$env:BROWSERSTACK_ACCESS_KEY="votre_access_key"
```

**Linux/Mac :**
```bash
export BROWSERSTACK_USERNAME="votre_username"
export BROWSERSTACK_ACCESS_KEY="votre_access_key"
```

### 2. Lancer les tests

```bash
npx playwright test --config=playwright.config.browserstack.js
```

### 3. Lancer un test spécifique

```bash
npx playwright test tests/01-account-creation.spec.js --config=playwright.config.browserstack.js
```

## Visualiser les résultats

1. Connectez-vous à [BrowserStack Automate](https://automate.browserstack.com/)
2. Vous verrez vos tests avec :
   - Vidéos des exécutions
   - Logs de la console
   - Logs réseau
   - Captures d'écran
   - Métadonnées

## Configuration avancée

Pour modifier la configuration BrowserStack (OS, version du navigateur, etc.), éditez le fichier `playwright.config.browserstack.js`.

Options disponibles :
- `browser`: 'chrome', 'firefox', 'edge', 'safari'
- `browser_version`: 'latest', '120', etc.
- `os`: 'Windows', 'OS X', 'Android', 'iOS'
- `os_version`: '11', '10', 'Monterey', etc.
- `browserstack.console`: 'disable', 'errors', 'warnings', 'info', 'verbose'
- `browserstack.networkLogs`: 'true' ou 'false'

Documentation complète : https://www.browserstack.com/docs/automate/playwright
