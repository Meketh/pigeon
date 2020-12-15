defmodule Util do
  defmacro ok?(call, opts, do_block \\ []) do
    opts = opts ++ do_block
    do_quote = Keyword.get(opts, :do, quote do ok end)
    match = Keyword.get(opts, :match, quote do ok end)
    else_quote = Keyword.get(opts, :else, quote do other end)
    quote do
       case unquote(call) do
        {:ok, unquote(match)} -> unquote(do_quote)
        other -> unquote(else_quote)
      end
    end
  end

  def run(fun, args \\ [])
  def run({m, f, a}, []), do: apply(m, f, a)
  def run({m, f, a}, extra), do: run({m, f, extra ++ a})
  def run(fun, args), do: apply(fun, args)
end
