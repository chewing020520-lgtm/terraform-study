# Terraform 학습 기록 🏗️

DevOps 엔지니어를 목표로 Terraform을 기초부터 학습하며 실습 코드를 기록하는 리포지토리입니다.
로컬 프로바이더로 핵심 개념을 익힌 뒤, AWS 인프라 구축 → 모듈화 → CI/CD 연동으로 확장할 예정입니다.

## 진행 현황

| 단계 | 주제 | 상태 |
|---|---|---|
| lesson1 | 기초 워크플로, 변수/출력, state | ✅ 완료 |
| lesson2 | AWS 프로바이더, IAM, 첫 S3 버킷 | ✅ 완료 |
| lesson3 | (예정) | 🔜 |

## lesson1 — 기초 워크플로

`random_pet`(랜덤 이름 생성)과 `local_file`(로컬 파일) 리소스로
`init → plan → apply → destroy` 사이클을 실습했.

**배운 것**

- Terraform은 선언형이다. "만들어라"가 아니라 "존재해야 한다"를 코드로 선언하면,
  현재 상태와 비교해 필요한 작업을 스스로 계산한다.
- 리소스 참조(`random_pet.server_name.id`)가 곧 의존성이 되어 생성 순서가 자동 결정된다.
- 속성에는 수정 가능한 것과 `forces replacement`(파괴 후 재생성)인 것이 있다.
  운영 환경에서 apply 전에 plan의 `-/+` 기호를 반드시 확인해야 하는 이유.
- `terraform.tfstate`는 Terraform의 장부다. 실제 리소스를 손으로 지우면
  plan이 드리프트를 감지해 재생성을 제안한다. state에는 비밀값이 평문으로
  저장되므로 git에 올리지 않는다.

  **실행 방법**

```bash
cd lesson1
terraform init
terraform plan
terraform apply                  # 기본값: [dev]
terraform apply -var="env=prod"  # 변수 주입: [prod]
terraform destroy                # 실습 후 정리
```


## lesson2 — AWS: 첫 S3 버킷

IAM 사용자 + 액세스 키로 AWS CLI를 연동하고, AWS 프로바이더로
S3 버킷을 생성/검증/삭제하는 전체 사이클을 실습했다.

**배운 것**

- S3 버킷 이름은 계정 단위가 아니라 **전 세계에서 유일**해야 한다.
  버킷 이름이 글로벌 URL의 일부가 되기 때문. 그래서 실무에서는
  이름에 회사명이나 랜덤 접미사를 붙인다 (`random_pet` 활용).
- 자격증명은 `aws configure`로만 저장한다. Terraform은 이를 자동으로
  찾아 쓰므로 코드에 키를 넣을 이유가 없고, 넣는 순간 유출 사고가 된다.
- `terraform destroy`는 **state에 기록된 리소스만** 지운다.
  계정에 있던 기존 버킷(CloudFormation 흔적)은 건드리지 않았다.
- `init`은 폴더 단위다. 폴더마다 독립된 프로바이더/lock/state를 가지므로
  새 실습 폴더의 첫 명령은 항상 `terraform init`.
- `required_providers`에 버전을 명시(`~> 6.0`)하는 것이 실무 정석.
  프로바이더 메이저 버전에 따라 동작이 달라질 수 있기 때문.

**실행 방법**

```bash
cd lesson2
terraform init
terraform plan
terraform apply
aws s3 ls           # 생성 확인
terraform destroy   # 실습 후 정리 (과금 방지)
```



## 리포 관리 원칙

- 커밋 전 `terraform fmt`로 코드 정렬
- `*.tfstate`, `.terraform/`, 실행 산출물은 `.gitignore`로 제외
- `.terraform.lock.hcl`은 버전 재현성을 위해 커밋에 포함