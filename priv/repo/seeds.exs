# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ElixirPlayground.Repo.insert!(%ElixirPlayground.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias ElixirPlayground.Repo
alias ElixirPlayground.Learning.Exercise

# Clear existing exercises (optional - comment out if you want to keep existing data)
Repo.delete_all(Exercise)

# Exercise 1: Variables and Basic Operations
Repo.insert!(%Exercise{
  title: "変数と基本演算",
  description: """
  Elixirでは、変数に値を代入して計算を行うことができます。

  **課題**: 2つの数値を足し算して結果を返してください。

  **ヒント**:
  - 変数は `変数名 = 値` の形式で定義します
  - 足し算は `+` 演算子を使います
  - 最後の式の結果が自動的に返されます
  """,
  initial_code: """
  # 2つの数値を定義してください
  a = 5
  b = 3

  # 足し算の結果を返してください
  """,
  solution: """
  a = 5
  b = 3
  a + b
  """,
  expected_output: "8",
  difficulty: "beginner",
  order: 1
})

# Exercise 2: String Concatenation
Repo.insert!(%Exercise{
  title: "文字列の結合",
  description: """
  Elixirでは、`<>` 演算子を使って文字列を結合できます。

  **課題**: "Hello, " と "Elixir!" を結合して "Hello, Elixir!" を返してください。

  **ヒント**:
  - 文字列はダブルクォート `"` で囲みます
  - `<>` 演算子で文字列を結合します
  """,
  initial_code: """
  # 2つの文字列を結合してください
  greeting = "Hello, "
  language = "Elixir!"

  # 結合した結果を返してください
  """,
  solution: """
  greeting = "Hello, "
  language = "Elixir!"
  greeting <> language
  """,
  expected_output: "\"Hello, Elixir!\"",
  difficulty: "beginner",
  order: 2
})

# Exercise 3: Lists
Repo.insert!(%Exercise{
  title: "リストの操作",
  description: """
  Elixirのリストは角括弧 `[]` で定義します。

  **課題**: リスト `[1, 2, 3]` の最初の要素を取得してください。

  **ヒント**:
  - `hd/1` 関数でリストの最初の要素（head）を取得できます
  - または `List.first/1` も使えます
  """,
  initial_code: """
  # リストを定義
  numbers = [1, 2, 3]

  # 最初の要素を取得してください
  """,
  solution: """
  numbers = [1, 2, 3]
  hd(numbers)
  """,
  expected_output: "1",
  difficulty: "beginner",
  order: 3
})

# Exercise 4: Anonymous Functions
Repo.insert!(%Exercise{
  title: "無名関数",
  description: """
  Elixirでは、`fn` キーワードを使って無名関数を定義できます。

  **課題**: 2つの数値を受け取って掛け算する無名関数を作成し、5と3で実行してください。

  **ヒント**:
  - 無名関数: `fn 引数 -> 処理 end`
  - 無名関数の呼び出し: `関数名.(引数)`
  - 掛け算は `*` 演算子を使います
  """,
  initial_code: """
  # 掛け算を行う無名関数を定義してください
  multiply = fn a, b ->
    # ここに処理を書いてください
  end

  # 5と3で関数を実行してください
  """,
  solution: """
  multiply = fn a, b -> a * b end
  multiply.(5, 3)
  """,
  expected_output: "15",
  difficulty: "beginner",
  order: 4
})

# Exercise 5: Pattern Matching
Repo.insert!(%Exercise{
  title: "パターンマッチング",
  description: """
  Elixirの強力な機能の1つがパターンマッチングです。
  `=` は代入ではなく、マッチング演算子です。

  **課題**: タプル `{:ok, 42}` から数値 42 を取り出してください。

  **ヒント**:
  - タプルは `{}` で定義します
  - パターンマッチング: `{:ok, value} = {:ok, 42}`
  - マッチした値を変数に束縛できます
  """,
  initial_code: """
  # タプルを定義
  result = {:ok, 42}

  # パターンマッチングで値を取り出してください
  """,
  solution: """
  result = {:ok, 42}
  {:ok, value} = result
  value
  """,
  expected_output: "42",
  difficulty: "beginner",
  order: 5
})

IO.puts("✅ Seeded #{Repo.aggregate(Exercise, :count)} exercises successfully!")
