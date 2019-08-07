defmodule Cldr.Message.Parser do
  @moduledoc false

  import NimbleParsec
  import Cldr.Message.Parser.Combinator

  def parse(rule \\ :message, input) when is_atom(rule) and is_binary(input) do
    apply(__MODULE__, rule, [input])
    |> unwrap
  end

  defparsec :message, message()
	
	defparsec :plural_message, plural_message()

  defp unwrap({:ok, acc, "", _, _, _}) when is_list(acc) do
    {:ok, acc}
  end

  defp unwrap({:ok, acc, rest, _, _, _}) when is_list(acc) do
    {:ok, acc, rest}
  end

  defp unwrap({:error, <<first::binary-size(1), reason::binary>>, rest, _, _, offset}) do
    {:error,
     {Cldr.Message.ParseError,
      "#{String.capitalize(first)}#{reason}. Could not parse the remaining #{inspect(rest)} " <>
        "starting at position #{offset + 1}"}}
  end
end
