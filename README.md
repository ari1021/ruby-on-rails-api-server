# ruby-on-rails-api-server

## rbenvのインストール
rubyのversion管理を行う [rbenv](https://github.com/rbenv/rbenv) をインストールします．

- まず，後々の比較のためにrubyのversionとインストール先を調べます．

```
ruby -v
which ruby
```

- (brewがインストールされている前提で)rbenvをインストールします．この際，ruby-buiidも同時にインストールされます．

```
brew install rbenv
(brew install ruby-build)
```

- pathを通したりします．

```
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(rbenv init -)"' >> ~/.zshrc
source ~/.zshrc
```

- rubyをインストールします．

```
rbenv install -L
rbenv install (欲しいversion)
rbenv versions
rbenv global (欲しいversion)
rbenv versions
```

- rubyのversionとインストール先を調べ，変わっているかどうかを確認します．

```
ruby -v
which ruby
```
この際，rubyのインストール先が `/Users/{name}/.rbenv/shims/ruby` になっていればokです．

- もし変わっていない場合は，pathが通っているかを確認します．

```
echo $PATH
```
で表示されるpathの中に，`/Users/{name}/.rbenv/shims` が入っているかを確認します．

入っていれば．もう一度以下のコマンドを打ち直します．

```
source ~/.zshrc
```

## gemのversion管理
gemは次のようにインストールすることができます．

```
gem install (欲しいもの)
```
しかし，このようにインストールしてしまうと，システムにインストールされ，システムの環境が汚れてしまいます．

そこで，bundlerを用いてプロジェクト毎にgemを管理します．

- Gemfileを作成します．

```
bundle init
```

- Gemfileを編集します．

生成されたGemfileは以下のようになっています．

```Gemfile
# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# gem "rails"
```
このGemfileに，`gem "欲しいもの", "欲しいversion"` という文を追加していきます．

例えば，railsの6.0.3.6をインストールしたければ，以下のようにします．

```Gemfile
# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem "rails", "6.0.3.6"
```

- gemをインストールします．

```
bundle install --path vendor/bundle
```

- インストールされているか確認します．
以下のコマンドでプロジェクトにインストールされているgemを確認することができます．

```
bundle exec gem list
```
一方，システムにインストールされているgemは以下のコマンドで確認することができます．

```
gem list
```

以上2つのコマンドを用いて，`"rails", "6.0.3.6"` が，プロジェクトにはインストールされているが，システムにはインストールされていないことを確認することができます．

## rails new
- `rails new`を行い，railsプロジェクトを作成します．

```
bundle exec rails new . -B -d mysql --skip-test --api
```

- configに情報を追加します．

```
brew info openssl
```
を叩き，`For compilers to find openssl you may need to set:`のところを見ます．

そこに書いてある情報を用いて，

```
bundle config --local build.mysql2 "--with-ldflags=-L/usr/local/opt/openssl@1.1/lib"
```
のようにします．

- `bundle install`を行います．
