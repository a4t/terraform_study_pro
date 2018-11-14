# Terraformのおさらい

## Terraformとは？

Hashicorp社が開発しているInfrastructure as Codeを実現するためのツール

主に各Cloud Providerが提供しているAPIを実行することに特化されている

## 対応しているProviderについて

https://www.terraform.io/docs/providers/

## 主な開発フロー

1. 各Provider用のTerraformコードを技術する
2. terraform planでdry runする
3. terraform applyで反映する
4. 新しく追加したいTerraformコードを記述する
5. terraform planでdry runする、この時 `3` で反映したものが含まれていないことを確認
6. terraform applyで反映する
7. `4` 以降を繰り返し

## Demo

```bash
terraform init
terraform apply
```


## 前回の実行との差分が何故わかるのか

terraform applyを実行すると `terraform.tfstate` というファイルが作成される

このファイルが現在の状況を保持している

追加分に関してはこの `terraform.tfstate` との差分をTerraformが計算し、結果に反映する

### tfstateについてのQ&A

- tfstateが消えてしまった場合どうなるか？
  - 現状の状態がわからなくなるので何もない状態、Terraformで記述されたコード全てを反映しようとする

- terraformを複数人で実行する場合tfstateはどうなるのか？
  - tfstateが共有されていないと2つの状態を持ってしまうことになるので危険な状態である
  - 解決案としてはS3にtfstateをアップロードして共有する方法がTerraform側で用意されている

- 複数のAWSアカウントを管理したい場合はどうすればいいか？
  - workspaceやaliasという機能があり、クロスアカウント問題は解決できる
  - workspaceの場合はtfstateも分割される


## Terraformを使うと何が良いか？

ほぼInfrastructure as Codeは何が良いか？と同義である

Terraformとよく比較されるのはCloudFormation

CloudFormationはAWSに特化したものであり、他のProviderを使用することができない

しかしCloudFormationはAWSに対してのアクションに特化しているため、AWS内での連携は非常にやりやすい

メリット・デメリットは何かとあるが実現するためのフローの違いであり、大きな違いとしてはクロスプロバイダができるかどうかという点である。

## その他

### Q&A

- Cloud側を手動で変更した場合どうなるか？
  - AWSやGCPは結構検知してくれるが他のサービスはあまり検知しない

- EC2のインスタンスタイプを変更したい場合はどうなるか？
  - EC2インスタンスの削除 -> EC2インスタンスという流れ

## 事故例

### DB喪失

#### 概要

RDSのインスタンスをスケールアップしようとしてm4.largeからm4.xlargeに変更した際に発生
Terraformではインスタンスタイプを変更するとインスタンスを作り直す挙動をする
そのため古いDBを捨てて、新しいDBを新規で立ち上げるという挙動をする

#### 対策

AWSのAPIやGUIからインスタンスタイプの変更を行う
その後、terraform importやtfstateを手動で書き換える

### Githubのアカウント全部喪失

#### 概要

Githubの仕様とTerraformの仕様がうまく噛み合ってなかったため発生した事故
結果的にGithubのOrganizationの権限がなくなってしまった

- TerraformでGitHubのチーム管理を自動化して事故った話
  - https://tsuchinoko.dmmlabs.com/?p=4265

#### 対策

Terraform実行用のユーザーを用意して自分自信はTerraformの管理下に入れない
変更の影響が大きそうな場合は手動対応も検討する
