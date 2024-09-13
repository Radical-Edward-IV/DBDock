# dbms-image-load.ps1

# 인코딩 설정
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# DBMS 종류와 버전 정보 배열 설정 (수정)
$databases = @(
#    @{ Name           = "Oracle";
#       Version        = "19.3c";
#       ImageName      = "wiseda/oracle:19.3c";
#       DefaultPath    = (Convert-Path ".\image\oracle\oracle-database-19.3c.tar");
#       ComposeFile    = ".\compose\oracle\oracle-19.3c-docker-compose.yml";
#       VmDataFilePath = "/opt/oracle/oradata";
#       ConnectionInfo = "Host: 127.0.0.1`nDatabase: ORCL(Service Name)`nPort: 1521`nUsername: wiseda`nPassword: wise1012" },

#   @{ Name           = "DB2";
#      Version        = "11.5.8.0";
#      ImageName      = "wiseda/db2:11.5.8.0";
#      DefaultPath    = (Convert-Path ".\image\db2\ibm-database-11.5.8.0.tar");
#      ComposeFile    = ".\compose\db2\db2-11.5.8-docker-compose.yml";
#      VmDataFilePath = "/database";
#      ConnectionInfo = "Host: 127.0.0.1`nDatabase: testdb`nPort: 50000`nUsername: db2inst1`nPassword: wise1012" },

    @{ Name           = "Postgres";
       Version        = "15.7";
       ImageName      = "postgres:15.7";
       DefaultPath    = (Convert-Path ".\image\postgres\postgres-database-15.7.tar");
       ComposeFile    = ".\compose\postgres\postgres-15.7-docker-compose.yml";
       VmDataFilePath = "/var/lib/postgresql/data";
       ConnectionInfo = "Host: 127.0.0.1`nDatabase: testdb`nPort: 5432`nUsername: wiseda`nPassword: wise1012" },
    @{ Name           = "Postgres";
       Version        = "14.12";
       ImageName      = "postgres:14.12";
       DefaultPath    = (Convert-Path ".\image\postgres\postgres-database-14.12.tar");
       ComposeFile    = ".\compose\postgres\postgres-14.12-docker-compose.yml";
       VmDataFilePath = "/var/lib/postgresql/data";
       ConnectionInfo = "Host: 127.0.0.1`nDatabase: testdb`nPort: 5432`nUsername: wiseda`nPassword: wise1012" },
    @{ Name           = "Postgres";
       Version        = "13.15";
       ImageName      = "postgres:13.15";
       DefaultPath    = (Convert-Path ".\image\postgres\postgres-database-13.15.tar");
       ComposeFile    = ".\compose\postgres\postgres-13.15-docker-compose.yml";
       VmDataFilePath = "/var/lib/postgresql/data";
       ConnectionInfo = "Host: 127.0.0.1`nDatabase: testdb`nPort: 5432`nUsername: wiseda`nPassword: wise1012" },
    @{ Name           = "Postgres";
       Version        = "12.19";
       ImageName      = "postgres:12.19";
       DefaultPath    = (Convert-Path ".\image\postgres\postgres-database-12.19.tar");
       ComposeFile    = ".\compose\postgres\postgres-12.19-docker-compose.yml";
       VmDataFilePath = "/var/lib/postgresql/data";
       ConnectionInfo = "Host: 127.0.0.1`nDatabase: testdb`nPort: 5432`nUsername: wiseda`nPassword: wise1012" },

    @{ Name             = "MariaDB";
       Version          = "11.4.2";
       ImageName        = "mariadb:11.4.2";
       DefaultPath      = (Convert-Path ".\image\mariadb\mariadb-database-11.4.2.tar");
       ComposeFile      = ".\compose\mariadb\mariadb-11.4.2-docker-compose.yml";
       VmDataFilePath   = "/var/lib/mysql";
       ConnectionInfo   = "Host: 127.0.0.1`nDatabase: testdb`nPort: 3306`nUsername: wiseda`nPassword: wise1012" },
    @{ Name             = "MariaDB";
       Version          = "10.11.9";
       ImageName        = "mariadb:10.11.9";
       DefaultPath      = (Convert-Path ".\image\mariadb\mariadb-database-10.11.9.tar");
       ComposeFile      = ".\compose\mariadb\mariadb-10.11.9-docker-compose.yml";
       VmDataFilePath   = "/var/lib/mysql";
       ConnectionInfo   = "Host: 127.0.0.1`nDatabase: testdb`nPort: 3306`nUsername: wiseda`nPassword: wise1012" }
)

# DBMS 목록 가져오기
$dbmsList = $databases | ForEach-Object { $_.Name } | Select-Object -Unique

# 사용자가 선택할 수 있도록 DBMS 목록 출력
Write-Host "=================================================="
Write-Host "Please select a DBMS:"
for ($i = 0; $i -lt $dbmsList.Count; $i++) {
    Write-Host "$($i + 1). $($dbmsList[$i])"
}

Write-Host ""
$dbmsSelection = Read-Host "Enter the number of the DBMS you want to use"
if ($dbmsSelection -lt 1 -or $dbmsSelection -gt $dbmsList.Count) { # ok
    Write-Host ""
    Write-Host "Invalid selection. Exiting..."
    Write-Host "=================================================="
    exit 1
}

# 선택된 DBMS 이름 가져오기
$selectedDBMS = $dbmsList[$dbmsSelection - 1]

# 해당 DBMS의 버전 목록 가져오기
$versionList = @($databases | Where-Object { $_.Name -eq ${selectedDBMS} } | ForEach-Object { $_.Version })

# 사용자가 선택할 수 있도록 버전 목록 출력
Write-Host "=================================================="
Write-Host "Please select a version of ${selectedDBMS}:"
for ($i = 0; $i -lt $versionList.Count; $i++) {
    Write-Host "$($i + 1). $($versionList[$i])"
}

Write-Host ""
$versionSelection = Read-Host "Enter the number of the version you want to use"
if ($versionSelection -lt 1 -or $versionSelection -gt $versionList.Count) { # ok
    Write-Host ""
    Write-Host "Invalid selection. Exiting..."
    Write-Host "=================================================="
    exit 1
}

# 선택된 DBMS와 버전 정보 가져오기
$selectedDB = $databases | Where-Object { $_.Name -eq $selectedDBMS -and $_.Version -eq $versionList[$versionSelection - 1] }
$imageName = $selectedDB.ImageName
$defaultPath = $selectedDB.DefaultPath
$composeFile = $selectedDB.ComposeFile
$vmDataFilePath = $selectedDB.VmDataFilePath
$connectionInfo = $selectedDB.ConnectionInfo

# Docker 이미지 존재 여부 확인
$imageExists = docker images -q $imageName
if (-not [string]::IsNullOrWhiteSpace($imageExists)) { # ok
    Write-Host "=================================================="
    Write-Host "Docker image ${imageName} already exists. Skipping load."
    Write-Host "=================================================="
} else { # ok
    # 파일 존재 여부를 확인합니다.
    if (Test-Path $defaultPath) {
        Write-Host "=================================================="
        Write-Host "Loading Docker image from ${defaultPath}..."

        # 비동기 작업을 위해 작업을 백그라운드 작업으로 시작
        $job = Start-Job -ScriptBlock {
            param ($defaultPath)
            docker load -i $defaultPath
            return $LASTEXITCODE
        } -ArgumentList $defaultPath

        # 변수 초기화
        $loadingMessage = "Loading image. Please wait"
        $dotCount = 0

        # Docker 이미지 로드 상태 확인
        while ($true) {
            $jobState = (Get-Job -Id $job.Id).State

            if ($jobState -eq "Completed") {
                # 작업 완료
                $jobResult = (Receive-Job -Id $job.Id)
                $LASTEXITCODE = $jobResult[-1]
                Remove-Job -Id $job.Id
                break
            }

            # 현재 메시지 출력
            Write-Host "$loadingMessage" -NoNewline

            for ($i = 0; $i -lt $dotCount; $i++) {
                Write-Host "." -NoNewline
            }
            Write-Host ""
            $dotCount = ($dotCount + 1) % 5

            # 1초 대기
            Start-Sleep -Seconds 5
        }

        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "Docker image loaded successfully."
            Write-Host "=================================================="
        } else {
            Write-Host ""
            Write-Host "Failed to load Docker image. Please check the .tar file and try again."
            Write-Host "=================================================="
            exit 1
        }
    } else { # ok
        Write-Host "=================================================="
        Write-Host "File does not exist at the specified path: ${defaultPath}"
        Write-Host "=================================================="
        exit 1
    }
}

# 데이터 파일 경로를 입력받습니다.
$dataFilePath = Read-Host "Please enter the path to the data file
ex) C:\Users\wiseda\ide\oradata
ex) C:\Users\wiseda\ide\IBM\DB2
"

# 설정 파일 경로를 입력받습니다.
$configFilePath
if (-not [string]::IsNullOrWhiteSpace($selectedDB.VmConfigFilePath)) {
	$configFilePath = Read-Host "Please enter the path to the config file
ex) C:\Users\wiseda\ide\mysql-config
"
}

if (-not (Test-Path $dataFilePath)) {
    Write-Host ""
    Write-Host "The specified data file path does not exist: ${dataFilePath}"
    Write-Host "=================================================="
    exit 1
}

# Docker Compose 파일 경로 설정
if (Test-Path $composeFile) {
    # docker-compose.yml 파일을 UTF-8로 읽고 수정합니다.
    $composeContent = Get-Content $composeFile -Raw -Encoding UTF8
    $backupContent = $composeContent.Clone()
    
    # 주석 해제 및 경로 수정
    $newVolumeEntry = "      - ${dataFilePath}:${vmDataFilePath}"
    $composeContent = $composeContent -replace "      - /path/to/datafile", $newVolumeEntry

    if (-not [string]::IsNullOrWhiteSpace($selectedDB.VmConfigFilePath)) {
        $newConfigVolumeEntry = "      - ${configFilePath}:${vmConfigFilePath}"
        $composeContent = $composeContent -replace "      - /path/to/configfile", $newConfigVolumeEntry
    }

    Set-Content -Path $composeFile -Value $composeContent -Encoding UTF8

    Write-Host ""
    Write-Host "docker-compose.yml updated with data file path: ${dataFilePath}:${vmDataFilePath}"
    Write-Host "=================================================="
    Write-Host "Starting Docker Compose..."
    docker-compose -f $composeFile up -d

    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "Docker Compose started successfully."

        # 최초 접속 방법 안내
        Write-Host ""
        Write-Host "To connect to your database, use the following information:"
        Write-Host ${ConnectionInfo}
        Write-Host "=================================================="
    } else {
        Write-Host ""
        Write-Host "Failed to start Docker Compose. Please check the docker-compose.yml file and try again."
        Write-Host "=================================================="
    }

    # 원래 내용으로 복원
    Set-Content -Path $composeFile -Value $backupContent -Encoding UTF8
    Write-Host "docker-compose.yml restored to original state."
    Write-Host "=================================================="

	# 유휴 상태
    exit 1
} else {
    Write-Host "docker-compose.yml file not found. Please check the docker-compose.yml file and try again."
    Write-Host "=================================================="
	
	# 유휴 상태
    exit 1
}
