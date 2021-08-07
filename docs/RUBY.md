### return省略
メソッドはreturnを書かなくても最後の式がreturnされる．

書かなくても良いではなくて，returnを書かないのが推奨されている？(要確認)

```ruby
def hoge(a, b)
    a + b
end

# これは以下と同じ
# def hoge(a, b)
#     return a + b
# end
```

### メソッド呼び出し
引数がないメソッドは`()`なしで呼び出すことができる．

```ruby
def hello
    p "hello, world!"
end

hello
# hello, world!
```

### rescue
`rescue`を用いることで例外処理を行うことができる．

```ruby
def zero_division
    1 / 0
rescue ZeroDivisionError => e
    p e
    raise e
end
```

### arrayへのアクセス
`[0]`や`[-1]`のようにアクセスするのではなく，`first`や`last`を使うことが推奨されている．

https://github.com/rubocop/ruby-style-guide#first-and-last

ruby自体には`second`や`third`は入っていない(昔は入っていたが今はない)が，ActiveRecordにはいまだに実装されているので使えたりする．

### xx ? yy : zz

```ruby
if xx
    yy
else
    zz
end
```
と同じ．

### freeze
immutableな変数にすることができる．

```ruby
DYNAMODB_TABLE_NAME = 'users'.freeze
```
破壊的操作はできないが，再代入はできる．

### resoucesとresouce
routingの設定ファイルには，`resources`を使ってroutingを設定することができる．

```ruby
resources :hoges

# 以下のroutingが設定される
#     hoges GET /hoges(.:format)          hoges#index
#           POST /hoges(.:format)         hoges#create
#  new_hoge GET /hoges/new(.:format)      hoges#new
# edit_hoge GET /hoges/:id/edit(.:format) hoges#edit
#      hoge GET /hoges/:id(.:format)      hoges#show
#           PATCH /hoges/:id(.:format)    hoges#update
#           PUT /hoges/:id(.:format)      hoges#update
#           DELETE /hoges/:id(.:format)   hoges#destroy
```
また，`resource`を使ってroutingを設定することができる．

```ruby
resource :hoge

# 以下のroutingが設定される
#  new_hoge GET    /hoge/new(.:format)     hoges#new
# edit_hoge GET    /hoge/edit(.:format)    hoges#edit
#      hoge GET    /hoge(.:format)         hoges#show
#           PATCH  /hoge(.:format)         hoges#update
#           PUT    /hoge(.:format)         hoges#update
#           DELETE /hoge(.:format)         hoges#destroy
#           POST   /hoge(.:format)         hoges#create
```

`only`を使うことで，必要のあるroutingだけを設定することができる．

```ruby
resources :hoges, only: [:index, :show, :create]

# 以下のroutingが設定される
#     hoges GET /hoges(.:format)          hoges#index
#           POST /hoges(.:format)         hoges#create
#      hoge GET /hoges/:id(.:format)      hoges#show
```

`resources`や`resource`はネストすることができる．

```ruby
resouces :hoges, only: [:index] do
    resource :fuga, only: [:destroy]
end

# 以下のroutingが設定される
#     hoges GET    /hoges(.:format)               hoges#index
#      fuga DELETE /hoges/:id/fuga(.:format)      fuga#destroy
```

### serializer
`render json:`とすると，通常はmodelのカラムが全て出力される．

不要な要素を出力しなかったり，新しい要素を出力するためにserializerを使うことができる．

serializerに定義したattributeだけが出力される．

```ruby
# Table name: hoges
# id
# name
# age
# email
# created_at

class HogeSerializer < ActiveModel::Serializer
    attribute :name
    attribute :email
end
```
上記のserializerを用いることで，以下のようなresponseになる．

```ruby
{
    "name": "string",
    "email": "string"
}
```
また，以下のように要素を追加することもできる．

```ruby
class HogeSerializer < ActiveModel::Serializer
    attribute :name
    attribute :email
    attribute :is_adult

    def is_adult
        object.age > 20 ? true : false
    end
end
```
さらに，serializerの呼び出し時に値を渡すこともでき，渡された値は`@instance_optioins`に保存される．
```ruby
class HogeSerializer < ActiveModel::Serializer
    attribute :name
    attribute :email
    attribute :fuga

    def fuga
        @instance_options[:fuga].blank? ? nil : @instance_options[:fuga]
    end
end

render json: hoge
# {
#     "name": "string",
#     "email": "string",
#     "fuga: nil
# }

render json: hoge, fuga: "fuuuuga"
# {
#     "name": "string",
#     "email": "string",
#     "fuga: "fuuuuga"
# }
```

### serializerの呼び出し
`render json:`とするときに，明示的にも暗黙的にもserializerを呼ぶことができる．

明示的に呼ぶ場合は，以下のようにする．

```ruby
# 単一のリソース
render json: hoge, serializer: HogeSerializer

# 複数のリソース
render json: hoges, each_serializer: HogeSerializer
```

暗黙的には，renderするオブジェクトのserializerが呼ばれる．

```ruby
render json: hoge
# HogeSerializerを探し，存在すれば呼ばれる．
```

### serializerのconfig
全てのAPIで統一したformatにするために，serializerのconfigを設定することができる．

defaultでは，単純なkey-valueとなっている．

```ruby
ActiveModelSerializers.config.adapter = ActiveModelSerializers::Adapter::JsonApi

{
  "data": {
    "id": "id",
    "type": "type",
    "attributes": {
      "name": "string",
      "email": "string",
    }
  }
}
```

(参考: https://github.com/rails-api/active_model_serializers/blob/v0.10.6/docs/general/adapters.md)


### rspec
以下のクラスをテストすることを考える．

```ruby
class User
    def initialize(name:, age:)
        @name = name
        @age = age
    end
    def greet
        if @age <= 12
            "ぼくは#{@name}だよ。"
        else
            "僕は#{@name}です。"
        end
    end
end
```
テストコードの例としては以下である．

```ruby
RSpec.describe User do
  describe '#greet' do
    let(:user) { User.new(name: 'たろう', age: age) }
    subject { user.greet }
    context '12歳以下の場合' do
      let(:age) { 12 }
      it { is_expected.to eq 'ぼくはたろうだよ。' }
    end
    context '13歳以上の場合' do
      let(:age) { 13 }
      it { is_expected.to eq '僕はたろうです。' }
    end
  end
end
```

`describe`はテストのグループ化を行う．

今回の場合だと，1つ目の`describe`はUserクラスというグループ，2つ目の`describe`はUserクラスのgreetメソッドというグループを表している．

`context`はテストの条件を分けることができる．

今回の場合だと，1つ目の`context`は12歳以下の場合に正常に動くか，2つ目の`context`は13才以上の場合に正常に動くかを表している．

`let`は変数を定義できるが，遅延評価されるという特徴を持つ．

今回の場合だと，

1. subject { user.greet } -> userは何？
1. let(:user) { User.new(name: 'たろう', age: age) } -> ageは何？
1. let(:age) { 12 }

のように呼ばれる．

`subject`はテスト対象のメソッドを引数にとり，`is_expected`で実行結果を呼び出すことができる．

また，`before`を用いることで，前処理を書くことができる．

さらに，モックを使いたい場合は，`double`でモックを作成し，`allow`でモックのメソッドを設定することができる．

#### db周りのテスト
[factory bot](https://github.com/thoughtbot/factory_bot)を用いてテストデータを用意する．

```ruby
FactoryBot.define do
  factory :hoge do
    name { "hoge_name" }
    age { 20 }
    email { "hoge@hoge.com" }
  end
end
```
その後，`let(:hoge) { create(:hoge) }`のようにテストデータを生成すれば良い．

#### serializerのテスト
単純にserializerを`new`で生成して，データを確認すれば良い．

(`ActiveModelSerializers.config.adapter = ActiveModelSerializers::Adapter::JsonApi`とする)

```ruby
# Table name: hoges
# id
# name
# age
# email
# created_at

class HogeSerializer < ActiveModel::Serializer
    attribute :name
    attribute :email
end
```
このserializerに対しては，以下のようなテストを書けば良い．

```ruby
RSpec.describe HogeSerializer do
  let(:serialization) { HogeSerializer.new(hoge) }
  let(:hoge) { create(:hoge) }

  subject { JSON.parse serialization.to_json }
  describe "attributes" do
    it "nameが正常に取得できる" do
      expect(subject["name"]).to eq "hoge_name"
    end
    it "ageが正常に取得できる" do
      expect(subject["age"]).to eq 20
    end
    it "emailが正常に取得できる" do
      expect(subject["email"]).to eq "hoge@hoge.com"
    end
  end
end
```

#### controllerのテスト
request specを用いれば良い．

```ruby
RSpec.describe "HogeController", type: :request do
  subject do
    get "/hoges", headers: headers
  end

  let(:headers) do
    {
      "x-token": access_token,
    }
  end
  let(:hoges) { create_list(:hoge, 2) }

  describe "#index" do
    describe "response code" do
      context "access_tokenが不正な場合" do
        let(:access_token) { "invalid_access_token" }
        it "401であること" do
          subject
          expect(response.status).to eq(401)
        end
      end
      context "正常なaccess_tokenを利用している場合" do
        let(:access_token) { "valid_access_token" }
        it "200であること" do
          subject
          expect(response.status).to eq(200)
        end
      end
    end

    describe "response body" do
      let(:access_token) { "valid_access_token" }
      let(:response_json) { JSON.parse(response.body) }
      describe "data" do
        # meta dataとかのテストを書いてもok
        # eg. describe "meta data" do ---- end
        describe "first data" do
          let(:res_data) { response_data.first }
          it "idが正常に取得できること" do
            subject
            expect(res_data["id"]).to eq hoges.first.id
          end
          it "typeが正常に取得できること" do
            subject
            expect(res_data["type"]).to eq "hoges"
          end
          describe "attribute" do
            let(:res_attribute) { res_data["attributes"] }
            it "nameが正常に取得できること" do
              subject
              expect(res_attribute["name"]).to eq hoges.first.name
            end
            it "ageが正常に取得できること" do
              subject
              expect(res_attribute["age"]).to eq hoges.first.age
            end
            it "emailが正常に取得できること" do
              subject
              expect(res_attribute["email"]).to eq hoges.first.email
            end
            it "created_atが正常に取得できること" do
              subject
              expect(res_attribute["created_at"]).to eq hoges.first.created_at
            end
          end
        end

        describe "second data" do
          let(:res_data) { response_data.second }
          it "idが正常に取得できること" do
            subject
            expect(res_data["id"]).to eq hoges.second.id
          end
          it "typeが正常に取得できること" do
            subject
            expect(res_data["type"]).to eq "hoges"
          end
          describe "attribute" do
            let(:res_attribute) { res_data["attributes"] }
            it "nameが正常に取得できること" do
              subject
              expect(res_attribute["name"]).to eq hoges.second.name
            end
            it "ageが正常に取得できること" do
              subject
              expect(res_attribute["age"]).to eq hoges.second.age
            end
            it "emailが正常に取得できること" do
              subject
              expect(res_attribute["email"]).to eq hoges.second.email
            end
            it "created_atが正常に取得できること" do
              subject
              expect(res_attribute["created_at"]).to eq hoges.second.created_at
            end
          end
        end
      end
    end
  end
end
```