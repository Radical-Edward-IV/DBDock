# DBDock 🐳

이 프로그램은 Docker 이미지를 로드하고, 다양한 <b>데이터베이스 관리 시스템(DBMS)</b>의 Docker Compose <b>구성을 자동화</b>합니다.   
사용자는 Oracle, DB2, Postgres, MariaDB 등의 다양한 DBMS와 버전을 선택하여, Docker 이미지를 로컬에 로드하고,   
데이터 파일 및 설정 파일 경로를 입력하여 Docker Compose 구성을 쉽게 완료할 수 있습니다.

현재 근무 중인 회사에서는 <b>여러 DBMS를</b> 설치하고 관리할 필요가 많아, 이를 <b>효율적으로 처리</b>하기 위해 이 프로그램을 개발했습니다.   
DBMS 버전이 변경되거나 용량이 부족한 상황에서 수작업으로 DBMS를 재설치하는 번거로움을 해결하기 위해 제작된 이 프로그램은,   
DBMS의 설치, 구성, 삭제를 간편하게 처리하여 개발 속도를 향상시키는 것을 목표로 하고 있습니다.

또한, <b>개인 프로젝트에서 로컬 DB 구성이 필요할 때에도 유용</b>하게 활용할 수 있습니다.

## 목차

<ol>
  <li><a href="#필수-요구사항">필수 요구사항</a></li>
  <li><a href="#설치-및-사용-방법">설치 및 사용 방법</a></li>
  <li><a href="#설정-방법">설정 방법</a></li>
  <li><a href="#문의">문의</a></li>
</ol>

## 필수 요구사항
- Docker
- WSL2
- PowerShell

## 설치 및 사용 방법

1. Docker 및 WSL2를 설치합니다.
2. 프로젝트를 클론합니다.
  ```bash
  git clone https://github.com/Radical-Edward-IV/DBDock.git
  ```
3. `run-dbms-load.bat` 파일을 더블 클릭하여 실행합니다.
4. DBMS를 선택하는 메뉴가 나타납니다. 원하는 DBMS를 선택합니다.
  ```bash
  ==================================================
  Please select a DBMS:
  1. Oracle
  2. DB2
  3. Postgres
  4. MariaDB
  
  Enter the number of the DBMS you want to use: 3
  ```
5. 선택한 DBMS의 버전을 선택하고 Docker 이미지가 로드될 때까지 대기합니다.
  ```bash
  ==================================================
  Please select a version of Postgres:
  1. 15.7
  2. 14.12
  3. 13.15
  4. 12.19
  
  Enter the number of the version you want to use: 1
  ==================================================
  Loading Docker image from C:\Users\GK\Desktop\02. Projects\기타\DBDock\image\postgres\postgres-database-15.7.tar...
  Loading image. Please wait
  Loading image. Please wait.
  Loading image. Please wait..
  
  Docker image loaded successfully.
  ```
6. 데이터 파일을 저장할 로컬 경로를 지정합니다.
  ```bash
  ==================================================
  Please enter the path to the data file
  ex) C:\Users\edward\ide\oradata
  ex) C:\Users\edward\ide\IBM\DB2
  : C:\Users\edward\datafiles\PostgreSQL\15\data
  
  docker-compose.yml updated with data file path: C:\Users\edward\datafiles\PostgreSQL\15\data:/var/lib/postgresql/data
  ==================================================
  Starting Docker Compose...
  time="2024-09-09T15:40:29+09:00" level=warning msg="C:\\Users\\edward\\DBDock\\compose\\postgres\\postgres-15.7-docker-compose.yml: `version` is obsolete"
  [+] Running 1/1
   ✔ Container postgres15  Started                                                                                   0.7s
  
  Docker Compose started successfully.
  ```
7. DBMS 접속 정보를 확인하여 데이터베이스에 접속합니다.
  ```base
  To connect to your database, use the following information:
  Host: 127.0.0.1
  Database: testdb
  Port: 5432
  Username: wiseda
  Password: wise1012
  ==================================================
  docker-compose.yml restored to original state.
  ==================================================
  Press any key to continue . . .
  ```

## 설정 방법
1. DBMS 이미지를 저장
    * `docker pull NAME[:TAG]` 명령어를 사용하여 Registry의 이미지를 다운로드 합니다.
    * `docker save -o [OPTIONS] IMAGE` 명령어를 사용하여 이미지를 로컬에 저장합니다.
    * 로컬에 저장한 이미지를 `DBDock/image/{database}` 디렉토리로 옮깁니다.
2. dbms-image-load.ps1 파일 편집
    * 저장한 DBMS 종류와 버전 정보를 $database 배열에 기존 항목을 참고하여 `@{}` 블록을 추가합니다.
3. {database}-docker-compose.yml 파일 추가
    * 기존 파일을 참고하거나, Docker Hub를 참고하여 도커 컴포즈 파일을 준비합니다.
    * 컴포즈 파일을 작성할 때 volumes 키의 값을 기존 파일과 동일하게 작성해야 합니다.
    * 로컬에 특정 DBMS가 설치되어 있는 경우 호스트 포트를 변경합니다.

## 문의
문의 사항은 Issues 페이지에서 남겨주세요.
