Clear-Host
$header = @"
             (                    
  *   )      )\ )                 
` )  /(   ( (()/(  (              
 ( )(_)|  )( /(_)) )(   (  `  )   
(_(_()))\(()(_))_ (()\  )\ /(/(   
|_   _((_)((_)   \ ((_)((_|(_)_\  
  | |/ _ \ '_| |) | '_/ _ \ '_ \) 
  |_|\___/_| |___/|_| \___/ .__/  
                          |_|        
"@
Write-Host $header -ForegroundColor Cyan
Write-Host "         TorDrop Installation / Установка TorDrop" -ForegroundColor Green
Write-Host

Write-Host "`nSelect language / Выберите язык:" -ForegroundColor Yellow
Write-Host "  1) " -NoNewline; Write-Host "English" -ForegroundColor White -BackgroundColor DarkGreen
Write-Host "  2) " -NoNewline; Write-Host "Русский" -ForegroundColor White -BackgroundColor DarkGreen

$langChoice = Read-Host -Prompt "Choose option / Выберите вариант [1]"
if ([string]::IsNullOrWhiteSpace($langChoice)) { $langChoice = "1" }

switch ($langChoice) {
    "2" {
        $LANG = @{
            STEP1 = "Шаг 1: Проверка системы"
            STEP2 = "Шаг 2: Выбор имени команды"
            STEP3 = "Шаг 3: Установка"
            STEP4 = "Шаг 4: Настройка окружения"
            SELECT_NAME = "Как вы хотите называть утилиту?"
            RECOMMENDED = "(рекомендуется)"
            SHORT = "(короткий вариант)"
            CUSTOM = "Своё имя"
            FILES_NOT_FOUND = "Ошибка: Не найдены необходимые файлы проекта. Убедитесь, что вы запускаете скрипт из корневой директории проекта."
            FILES_FOUND = "✓ Файлы проекта найдены."
            PYTHON_NOT_FOUND = "Ошибка: Python не найден в PATH. Пожалуйста, установите Python с python.org"
            PYTHON_FOUND = "✓ Python 3 найден."
            VENV_NOT_FOUND = "Ошибка: Модуль 'venv' для Python не найден. Переустановите Python с включенным компонентом 'venv'."
            VENV_FOUND = "✓ Модуль 'venv' найден."
            TOR_NOT_FOUND = "Внимание: Tor не найден в системе. Пожалуйста, установите Tor отдельно или поместите исполняемый файл в папку проекта."
            TOR_FOUND = "✓ Tor найден в системе."
            EMPTY_NAME = "Имя не может быть пустым. Используем 'tordrop'."
            NAME_SELECTED = "Выбрано имя:"
            CREATE_ENV = "Создание окружения в"
            INSTALLING_DEPS = "Установка зависимостей (это может занять некоторое время)..."
            DEPS_ERROR = "Ошибка: Не удалось установить зависимости."
            DEPS_INSTALLED = "✓ Зависимости установлены."
            CREATING_LAUNCHER = "Создание лаунчера в"
            LAUNCHER_CREATED = "✓ Лаунчер создан."
            PATH_ADDED = "✓ Директория добавлена в PATH:"
            PATH_EXISTS = "Директория уже в PATH:"
            INSTALL_COMPLETE = "✅ Установка завершена!"
            CMD_INSTALLED = "Команда была успешно установлена."
            RESTART_NEEDED = "ЧТОБЫ НАЧАТЬ, ПЕРЕЗАПУСТИТЕ ВАШ ТЕРМИНАЛ!"
            EXAMPLE = "Пример:"
            UNINSTALL = "Удаление: Удалите директории"
            ENTER_NAME = "Введите желаемое имя команды"
            SELECT_OPTION = "Выберите вариант"
            TOR_INSTRUCTIONS = "ВАЖНО: Tor должен быть установлен в системе или помещен в папку проекта как 'tor.exe' исполняемый файл."
        }
    }
    default {
        $LANG = @{
            STEP1 = "Step 1: System Check"
            STEP2 = "Step 2: Command Name Selection"
            STEP3 = "Step 3: Installation"
            STEP4 = "Step 4: Environment Setup"
            SELECT_NAME = "How would you like to name the utility?"
            RECOMMENDED = "(recommended)"
            SHORT = "(short version)"
            CUSTOM = "Custom name"
            FILES_NOT_FOUND = "Error: Required project files not found. Make sure you're running the script from the project root directory."
            FILES_FOUND = "✓ Project files found."
            PYTHON_NOT_FOUND = "Error: Python not found in PATH. Please install Python from python.org"
            PYTHON_FOUND = "✓ Python 3 found."
            VENV_NOT_FOUND = "Error: Python 'venv' module not found. Reinstall Python with 'venv' component enabled."
            VENV_FOUND = "✓ Module 'venv' found."
            TOR_NOT_FOUND = "Warning: Tor not found in system. Please install Tor separately or place the executable file in the project folder."
            TOR_FOUND = "✓ Tor found in system."
            EMPTY_NAME = "Name cannot be empty. Using 'tordrop'."
            NAME_SELECTED = "Selected name:"
            CREATE_ENV = "Creating environment in"
            INSTALLING_DEPS = "Installing dependencies (this might take a while)..."
            DEPS_ERROR = "Error: Failed to install dependencies."
            DEPS_INSTALLED = "✓ Dependencies installed."
            CREATING_LAUNCHER = "Creating launcher in"
            LAUNCHER_CREATED = "✓ Launcher created."
            PATH_ADDED = "✓ Directory added to PATH:"
            PATH_EXISTS = "Directory already in PATH:"
            INSTALL_COMPLETE = "✅ Installation complete!"
            CMD_INSTALLED = "Command has been successfully installed."
            RESTART_NEEDED = "TO START USING, RESTART YOUR TERMINAL!"
            EXAMPLE = "Example:"
            UNINSTALL = "To uninstall: Remove directories"
            ENTER_NAME = "Enter desired command name"
            SELECT_OPTION = "Choose option"
            TOR_INSTRUCTIONS = "IMPORTANT: Tor must be installed in the system or placed in the project folder as 'tor.exe' executable file."
        }
    }
}

Write-Host "`n---[ $($LANG.STEP1) ]---" -ForegroundColor Yellow

# Check required files
$requiredFiles = @("tordrop.py", "requirements.txt", "templates\index.html", "templates\simple_index.html", "static\style.css")
foreach ($file in $requiredFiles) {
    if (-not (Test-Path $file)) {
        Write-Host $LANG.FILES_NOT_FOUND -ForegroundColor Red
        exit 1
    }
}
Write-Host $LANG.FILES_FOUND

$pythonPath = Get-Command python -ErrorAction SilentlyContinue
if (-not $pythonPath) {
    Write-Host $LANG.PYTHON_NOT_FOUND -ForegroundColor Red
    exit 1
}
Write-Host $LANG.PYTHON_FOUND

try { & $pythonPath.Source -m venv --help > $null } catch {
    Write-Host $LANG.VENV_NOT_FOUND -ForegroundColor Red
    exit 1
}
Write-Host $LANG.VENV_FOUND

# Check Tor
$torPath = Get-Command tor -ErrorAction SilentlyContinue
if (-not $torPath) {
    Write-Host $LANG.TOR_NOT_FOUND -ForegroundColor Yellow
} else {
    Write-Host $LANG.TOR_FOUND
}

Write-Host "`n$($LANG.TOR_INSTRUCTIONS)" -ForegroundColor Yellow

Write-Host "`n---[ $($LANG.STEP2) ]---" -ForegroundColor Yellow
Write-Host "$($LANG.SELECT_NAME)`n"
Write-Host "  1) " -NoNewline; Write-Host "tordrop" -ForegroundColor White -BackgroundColor DarkGreen -NoNewline; Write-Host " $($LANG.RECOMMENDED)"
Write-Host "  2) " -NoNewline; Write-Host "td" -ForegroundColor White -BackgroundColor DarkGreen -NoNewline; Write-Host "      $($LANG.SHORT)"
Write-Host "  3) $($LANG.CUSTOM)"
Write-Host

$choice = Read-Host -Prompt "$($LANG.SELECT_OPTION) [1]"
if ([string]::IsNullOrWhiteSpace($choice)) { $choice = "1" }

switch ($choice) {
    "2" { $commandName = "td" }
    "3" { 
        $customName = Read-Host $LANG.ENTER_NAME
        if ([string]::IsNullOrWhiteSpace($customName)) {
            Write-Host $LANG.EMPTY_NAME -ForegroundColor Yellow
            $commandName = "tordrop"
        } else {
            $commandName = $customName
        }
    }
    default { $commandName = "tordrop" }
}
Write-Host "$($LANG.NAME_SELECTED) " -NoNewline; Write-Host $commandName -ForegroundColor Green

Write-Host "`n---[ $($LANG.STEP3) ]---" -ForegroundColor Yellow
$appDir = Join-Path $env:LOCALAPPDATA "tordrop"
Write-Host "$($LANG.CREATE_ENV) '$appDir'..."
if (Test-Path $appDir) { Remove-Item -Recurse -Force $appDir }
New-Item -ItemType Directory -Force $appDir | Out-Null

# Copy project files
Copy-Item "tordrop.py" -Destination $appDir
Copy-Item "requirements.txt" -Destination $appDir
Copy-Item "templates" -Destination $appDir -Recurse
Copy-Item "static" -Destination $appDir -Recurse

& $pythonPath.Source -m venv "$appDir\venv"

Write-Host $LANG.INSTALLING_DEPS
$pipPath = Join-Path $appDir "venv\Scripts\pip.exe"
& $pipPath install --upgrade pip --quiet
& $pipPath install -r "$appDir\requirements.txt" --quiet
if ($LASTEXITCODE -ne 0) {
    Write-Host $LANG.DEPS_ERROR -ForegroundColor Red; exit 1
}
Write-Host $LANG.DEPS_INSTALLED

$scriptsDir = Join-Path $env:USERPROFILE ".local\bin"
New-Item -ItemType Directory -Force $scriptsDir | Out-Null
$launcherPath = Join-Path $scriptsDir "$commandName.bat"
Write-Host "$($LANG.CREATING_LAUNCHER) '$launcherPath'..."
$launcherContent = @"
@echo off
setlocal
set "APP_HOME=%LOCALAPPDATA%\tordrop"
"%APP_HOME%\venv\Scripts\python.exe" "%APP_HOME%\tordrop.py" %*
endlocal
"@
Set-Content -Path $launcherPath -Value $launcherContent
Write-Host $LANG.LAUNCHER_CREATED

Write-Host "`n---[ $($LANG.STEP4) ]---" -ForegroundColor Yellow
$userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
if (-not ($userPath -split ';' -contains $scriptsDir)) {
    [System.Environment]::SetEnvironmentVariable("Path", "$userPath;$scriptsDir", "User")
    Write-Host "$($LANG.PATH_ADDED) '$scriptsDir'"
} else {
    Write-Host "$($LANG.PATH_EXISTS) '$scriptsDir'"
}

Write-Host "`n-----------------------------------------------------" -ForegroundColor DarkGray
Write-Host $LANG.INSTALL_COMPLETE -ForegroundColor Green
Write-Host "$($LANG.CMD_INSTALLED) '$commandName'"
Write-Host $LANG.RESTART_NEEDED -ForegroundColor Yellow
Write-Host
Write-Host "$($LANG.EXAMPLE) " -NoNewline; Write-Host "$commandName C:\path\to\your\file.zip" -ForegroundColor Cyan
Write-Host "$($LANG.UNINSTALL) '$appDir' and '$launcherPath'" -ForegroundColor DarkGray
Write-Host "-----------------------------------------------------" -ForegroundColor DarkGray