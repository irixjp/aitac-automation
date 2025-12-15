# Playbookの記述と実行

先の演習ではAd-Hocコマンドを利用してモジュールを1つずつ実行しましたが、これはこれで便利な場面もありますが、実際に作業を行う場合はいくつのも手順を連続して実行することになります。その際に、順番に Ad-Hoc コマンドを実行するは手間がかかります。そこで、モジュールを順番に並べて一括して実行するために `playbook` (プレイブック)を作成します。playbook に呼出したいモジュールとパラメーターを順番に記述し、`ansible-playbook` コマンドに読み込ませることで、playbook の内容を一括して実行することが可能となります。

Ansible でインフラを自動化するには、まず最初に Playbook を作成することから始まります。

> Note: ただし、Playbook が揃えば自動化は完了するかというと、そうではありません。確かに Playbook は現場の手順を置き換えてくれますが、それはインフラ作業における一部分です。更に自動化を進めて効率化を進めるには、自動化をサービス提供の手段と活用して、「人の調整を減らす」ことや、 [インフラCI](https://www.shoeisha.co.jp/book/detail/9784798155128) によって「品質を担保するための作業」を自動化していくことも必要となります。これを忘れずに、決して Ansible を使うことや、 Playbook を書くこと自体が目的化しないように注意してください。


## Playbook の基礎

`playbook` は [YAML](https://ja.wikipedia.org/wiki/YAML) 形式で記述します。YAMLに関して重要なポイントを以下に記載します。

- YAML はデータを表記するためのテキストフォーマットであること。
- ファイルの先頭は `---` から始まる
- インデントが意味を持つ
  - インデントは `space` で表記する。`tab` ではエラーとなります。
- `key`: `value` で辞書形式となる
- [json](https://ja.wikipedia.org/wiki/JavaScript_Object_Notation) と相互に変換可能

以下は playbook のサンプルです。
```yaml
---
- hosts: all
  become: yes
  tasks:
  - name: first task
    ansible.builtin.dnf:
      name: httpd
      state: latest
  - name: second task
    ansible.builtin.service:
      name: httpd
      state: started
      enabled: yes
```

この内容は、json で表記すると以下のようになります。

```json
[
	{
		"hosts": "all",
		"become": "yes",
		"tasks": [
			{
				"name": "first task",
				"ansible.builtin.dnf": {
					"name": "httpd",
					"state": "latest"
				}
			},
			{
				"name": "second task",
				"ansible.builtin.service": {
					"name": "httpd",
					"state": "started",
					"enabled": "yes"
				}
			}
		]
	}
]
```

この Playbook は Excel に変換すると以下のようなイメージになります。

![yaml_to_excel.png](https://raw.githubusercontent.com/irixjp/aitac-automation/main/101_ansible_basic/images/yaml_to_excel.png)

YAMLはデータ構造を表現するためのフォーマットであるため、このような変換が可能となります。

> Note: Excel から YAML への変換も技術的には可能ですが、一般的にはあまり行われません。人が編集した Excel にはセル結合や余白セルが含まれるため、単純なルールで変換出来ないためです。

## playbook の作成

実際に playbook を作成していきます。

`~/working/first_playbook.yml` をエディタで開いてください。このファイルには先頭に `---` のみが記載されています。以下の説明に従いこのファイルへ追記を行い、playbook として完成させます。

> Note:  `~` はホームディレクトリの短縮表現で、 `/student` や `$HOME` と同じ意味です。

ここでは、WEBサーバーを構築する playbook を作成します。

### 🔸play パート

以下のようにファイルに追記してください。

![edit_file.png](https://raw.githubusercontent.com/irixjp/aitac-automation/main/101_ansible_basic/images/edit_file.png)
```yaml
---
- name: deploy httpd server
  hosts: web
  become: yes
```

ここで記述した内容な以下になります。
- `name:`: ここには、この playbook で行う処理の概要を記載します。省略可能です。日本語を使うことも可能です。
- `hosts: web`: playbook の実行対象となるグループやノードを指定します。これは利用するインベントリー内に存在しているグループやノードである必要があります。
- `become: yes`: この playbook では実行時に特権ユーザーへの権限昇格を行うことを宣言しています。ansible コマンドで利用した `-b` と同じ意味です。

この部分は、playbook 内の `play` パートと呼ばれる部分で全体に関する挙動を宣言します。playbook全体のヘッダーのようなものだと理解してください。playパートで指定できる項目の[詳細については公式ドキュメント](https://docs.ansible.com/projects/ansible/latest/reference_appendices/playbooks_keywords.html#play) を確認してください。

### 🔸task パート

次に以下の状態となるように先のファイルへ追記します。インデントの階層に注意してください。

![edit_file.png](https://raw.githubusercontent.com/irixjp/aitac-automation/main/101_ansible_basic/images/edit_file.png)
```yaml
---
- name: deploy httpd server
  hosts: web
  become: yes
  tasks:
  - name: install httpd
    ansible.builtin.dnf:
      name: httpd
      state: latest

  - name: start & enabled httpd
    ansible.builtin.service:
      name: httpd
      state: started
      enabled: yes
```

ここで追記した内容は `task` パートと呼ばれる部分になり、実際にこの playbook が行う処理を記述していきます。task パートではモジュールを呼び出す順番に列挙し、あわせてモジュールに対して必要なパラメーターを与えます。

- `tasks:` これ以降が task パートであることを宣言しています。
- `- name: ...` このタスクの説明を記載しています。省略可能
- `ansible.builtin.dnf:` `ansible.builtin.service:` 呼び出すモジュールを指定しています。
- 以下はモジュールに与えられているパラメーターです。
  - `name: httpd` `state: latest`
  - `name: httpd` `state: started` `enabled: yes`

ここで呼び出しているモジュールは以下になります。
- `ansible.builtin.dnf`: httpd パッケージをインストールするために利用します。
- `ansible.builtin.service`: インストールされた httpd を起動し、自動起動の設定を有効にしています。

作成した playbook に構文エラーがないかを以下のコマンドで確認できます。

![run_command.png](https://raw.githubusercontent.com/irixjp/aitac-automation/main/101_ansible_basic/images/run_command.png)
`cd ~/working`

![run_command.png](https://raw.githubusercontent.com/irixjp/aitac-automation/main/101_ansible_basic/images/run_command.png)
`ansible-playbook first_playbook.yml --syntax-check`

```text
playbook: first_playbook.yml
```

上記はエラー無しのケースです。もしインデントなどに誤りがある場合は以下のようになります。
```text
$ ansible-playbook first_playbook.yml --syntax-check

[ERROR]: YAML parsing failed: While parsing a block mapping did not find expected key.
Origin: /student/test1.yaml:9:7

7     ansible.builtin.dnf:
8        name: httpd
9       state: latest
        ^ column 7
```

この場合には、playbook のインデントなどがサンプルと同じになっているかを再度確認してください。

## playbook の実行

作成した playbook を実行します。playbook の実行には `ansible-playbook` コマンドを利用します。成功すれば httpd サーバーが起動して apache の初期画面が参照できるはずです。

![run_command.png](https://raw.githubusercontent.com/irixjp/aitac-automation/main/101_ansible_basic/images/run_command.png)
`ansible-playbook first_playbook.yml`

```text
PLAY [deploy httpd server] **************************************************

TASK [Gathering Facts] ******************************************************
ok: [node2]
ok: [node3]
ok: [node1]

TASK [install httpd] ********************************************************
changed: [node1]
changed: [node2]
changed: [node3]

TASK [start & enabled httpd] ************************************************
changed: [node1]
changed: [node2]
changed: [node3]

PLAY RECAP ******************************************************************
node1  : ok=3 changed=2 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
node2  : ok=3 changed=2 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
node3  : ok=3 changed=2 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
```

上記のような出力となれば成功です。node1,2,3 に対してブラウザでアクセスしてサイトの動作を確認してください。

アクセス先のIPアドレスを調べるには以下のコマンドを実行します。

![run_command.png](https://raw.githubusercontent.com/irixjp/aitac-automation/main/101_ansible_basic/images/run_command.png)
`curl 169.254.169.254/latest/meta-data/public-ipv4`

- node1: http://<自分の code-server IPアドレス>:8081
- node2: http://<自分の code-server IPアドレス>:8082
- node3: http://<自分の code-server IPアドレス>:8083

apache の初期画面が表示されれば成功です。アクセス出来ない場合には設定に失敗している可能性があります。Playbookと実行コマンドを確認してください。


## タスクの追加

作成した playbook にサイトのトップページを配布するタスクを追加します。

`~/working/files/index.html` をエディタで開きます。

ファイルを以下のように編集します。
```html
<body>
<h1>Apache is running fine</h1>
</body>
```

さらに `first_playbook.yml` を以下のように編集します。

![edit_file.png](https://raw.githubusercontent.com/irixjp/aitac-automation/main/101_ansible_basic/images/edit_file.png)
```yaml
---
- name: deploy httpd server
  hosts: web
  become: yes
  tasks:
  - name: install httpd
    ansible.builtin.dnf:
      name: httpd
      state: latest

  - name: start & enabled httpd
    ansible.builtin.service:
      name: httpd
      state: started
      enabled: yes

  - name: copy index.html
    ansible.builtin.copy:
      src: files/index.html
      dest: /var/www/html/
```

編集が完了したら、構文チェックを実施した後に playbook を実行してみましょう。

![run_command.png](https://raw.githubusercontent.com/irixjp/aitac-automation/main/101_ansible_basic/images/run_command.png)
`ansible-playbook first_playbook.yml --syntax-check`

![run_command.png](https://raw.githubusercontent.com/irixjp/aitac-automation/main/101_ansible_basic/images/run_command.png)
`ansible-playbook first_playbook.yml`

```text
PLAY [deploy httpd server] **************************************************

TASK [Gathering Facts] ******************************************************
ok: [node2]
ok: [node3]
ok: [node1]

TASK [install httpd] ********************************************************
ok: [node1]
ok: [node3]
ok: [node2]

TASK [start & enabled httpd] ************************************************
ok: [node2]
ok: [node1]
ok: [node3]

TASK [copy index.html] ******************************************************
changed: [node1]
changed: [node3]
changed: [node2]

PLAY RECAP ******************************************************************
node1  : ok=4 changed=1 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
node2  : ok=4 changed=1 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
node3  : ok=4 changed=1 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
```

正常終了したら再びブラウザで3台のノードへアクセスしてください。正しく playbook が記述され、動作したのならば先程作成した `index.html` の内容が表示されるはずです。

> Note: `curl` コマンドを使って `curl node1` のように実行して確認してもOKです。


## 冪等性(べきとうせい)

Ansible のモジュールを利用するメリットして、記述量を大幅に減らせるという解説を行いましたが、その他にもメリットがあります。それが `冪等性` です。

この演習では `ansible-playbook first_playbook.yml` を2回実行しています。httpd のインストールと起動を行った時、そしてサイトのトップページを追加したときです。つまり、httpd のインストールと起動のタスクは2回実行されています。しかし、2回目の playbook 実行にもエラー等は起きていません。これは Ansible の `冪等性` が機能しているからです。

1回目の実行結果と2回目の実行結果を注意深く確認すると、出力結果に違いがあることに気づくはずです。異なる箇所は、それぞれの処理において `changed` と出力されたか、`ok`と出力されたかです。

- `changed`: Ansibleが処理を実行した結果、対象ホストの状態が変わった（Ansibleが実際に設定を行った）
- `ok`: Ansibleは処理を行おうとしたが、既に想定した設定になっているので状態が変わらなかった（Ansibleは設定を行わなかった・行う必要がなかった）

この動作が Ansible が備える冪等性になります。Ansible は今から行おうとする処理を実行する必要があるのか、無いのかを実行前に判断してくれています。

ここで再度この playbook を実行してみましょう。3つのタスクの状態がどのようになるか考えてから実行してください。

![run_command.png](https://raw.githubusercontent.com/irixjp/aitac-automation/main/101_ansible_basic/images/run_command.png)
`ansible-playbook first_playbook.yml`

```text
PLAY [deploy httpd server] **************************************************

TASK [Gathering Facts] ******************************************************
ok: [node3]
ok: [node1]
ok: [node2]

TASK [install httpd] ********************************************************
ok: [node2]
ok: [node1]
ok: [node3]

TASK [start & enabled httpd] ************************************************
ok: [node1]
ok: [node2]
ok: [node3]

TASK [copy index.html] ******************************************************
ok: [node3]
ok: [node1]
ok: [node2]

PLAY RECAP ******************************************************************
node1  : ok=4 changed=0 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
node2  : ok=4 changed=0 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
node3  : ok=4 changed=0 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
```

全てのタスクは `ok` となったはずです。playbook 実行時の最後の `PLAY RECAP` 部分を並べてみると結果の差が分かりやすく確認できます。ここでは各ノードにおいて、何個のタスクが `changed` になったのかを比較してください。


1回目(タスク2個がchanged)
```text
PLAY RECAP ******************************************************************
node1  : ok=3 changed=2 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
node2  : ok=3 changed=2 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
node3  : ok=3 changed=2 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
```

2回目(タスク1個がchanged)
```text
PLAY RECAP ******************************************************************
node1  : ok=4 changed=1 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
node2  : ok=4 changed=1 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
node3  : ok=4 changed=1 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
```

3回目(changedは0)
```text
PLAY RECAP ******************************************************************
node1  : ok=4 changed=0 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
node2  : ok=4 changed=0 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
node3  : ok=4 changed=0 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
```

では、この冪等性は何が嬉しいのかというと、

- Playbookには「処理の手順ではなく、状態を宣言的に記述できる」→ Playbook＝設定パラメータ＋手順書として扱えるようになる。
- 仮に複数台のホストに対して実行した処理が途中で失敗しても、最初から流し直せる（設定が成功した部分はスキップ(ok)されるため）
- 手順の集約ができる。初期設定、ノードの追加など様々なシーンを１つのPlaybookだけでカバーできるようになる。

> Note: 特に最後の「手順を集約する」という部分は重要です。従来ならば状況に応じて個別に作成する必要があったものを、冪等性を活用することで1本化して自動化することが可能です。冪等性をうまく活用することができれば、作業を自動化して効率化するだけではなく、自動化の開発そのものも大きく効率化できます。

Ansible の各モジュールはこの冪等性を考慮するように作られており、このモジュールを利用することで簡単に、そして安全に自動化を記述することができるようになっています。

これが自作の自動化シェルスクリプトの場合、特に失敗ややり直し時の再実行において、スクリプトを頭から流し直していいのか？ダメなのか？等の面倒な考慮点が生まれてしまうことは容易に想像できると思います(途中から実行する場合の手順や別のスクリプトを準備したり・・・)

> Note: ただし、Ansibleも全てのモジュールが完全な冪等性を保証しているわけではありません。モジュールの中には shell のように何が実行されるかわからないものや、操作対象（NW系機器やクラウド環境）によっては原理的に冪等性の確保が難しいものも存在しています。こういったモジュールを使う場合は利用者が注意を払う必要があります。

## 演習の解答

- [first\_playbook.yml](https://github.com/irixjp/aitac-automation/blob/main/101_ansible_basic/solutions/first_playbook.yml)
- [files/index.html](https://github.com/irixjp/aitac-automation/blob/main/101_ansible_basic/solutions/files/index.html)
