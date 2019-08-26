defmodule Cldr_Messages_Test do
  use ExUnit.Case
  doctest Cldr.Message

  test "arguments are inserted positionally" do
    assert Cldr.Message.format("{0} {1, plural,
      one {est {2, select, female {allée} other  {allé}}}
      other {sont {2, select, female {allées} other {allés}}}
    } à {3}", ["You", 3, "female", "three"], []) ==
             {:ok, ["You", " ", "sont allées", " à ", "three"]}
  end

  test "keyword selectors" do
    assert Cldr.Message.format("You have {item_count, plural,
        =0 {no items}
        one {1 item}
        other {{item_count} items}
    }", item_count: 1, items: 3) == {:ok, ["You have ", "1 item"]}
  end

  test "numbers in percent format" do
    assert Cldr.Message.format("{taxable_area, select,
        yes {An additional {tax_rate, number, percent} tax will be collected.}
        other {No taxes apply.}
    }", taxable_area: "yes", tax_rate: 0.15) ==
             {:ok, ["An additional 15% tax will be collected."]}
  end

  test "select other category" do
    assert Cldr.Message.format("{taxable_area, select,
        yes {An additional {tax_rate, number, percent} tax will be collected.}
        other {No taxes apply.}
    }", taxable_area: "no", tax_rate: 0.15) == {:ok, ["No taxes apply."]}
  end

  test "explicit selector" do
    assert Cldr.Message.format("You have {item_count, plural,
        =0 {no items}
        one {1 item}
        other {{item_count} items}
    }",
             item_count: 0
           ) == {:ok, ["You have ", "no items"]}
  end

  test "other keyword selector" do
    assert Cldr.Message.format("You have {item_count, plural,
        =0 {no items}
        one {1 item}
        other {{item_count} items}
    }",
             item_count: 2
           ) == {:ok, ["You have ", "2 items"]}
  end

  test "nested complex arguments" do
    assert Cldr.Message.format(
             "{gender_of_host, select,
      female {
        {num_guests, plural, offset: 1
          =0 {{host} does not give a party.}
          =1 {{host} invites {guest} to her party.}
          =2 {{host} invites {guest} and one other person to her party.}
          other {{host} invites {guest} and # other people to her party.}}}
      male {
        {num_guests, plural, offset: 1
          =0 {{host} does not give a party.}
          =1 {{host} invites {guest} to his party.}
          =2 {{host} invites {guest} and one other person to his party.}
          other {{host} invites {guest} and # other people to his party.}}}
      other {
        {num_guests, plural, offset: 1
          =0 {{host} does not give a party.}
          =1 {{host} invites {guest} to their party.}
          =2 {{host} invites {guest} and one other person to their party.}
          other {{host} invites {guest} and # other people to their party.}}}}",
      gender_of_host: "male", host: "kip", guest: "jim", num_guests: 1
           ) ==
             {:ok, ["kip invites jim to his party."]}
  end

  test "offset" do
    assert Cldr.Message.format(
             "{gender_of_host, select,
      female {
        {num_guests, plural, offset: 1
          =0 {{host} does not give a party.}
          =1 {{host} invites {guest} to her party.}
          =2 {{host} invites {guest} and one other person to her party.}
          other {{host} invites {guest} and # other people to her party.}}}
      male {
        {num_guests, plural, offset: 1
          =0 {{host} does not give a party.}
          =1 {{host} invites {guest} to his party.}
          =2 {{host} invites {guest} and one other person to his party.}
          other {{host} invites {guest} and # other people to his party.}}}
      other {
        {num_guests, plural, offset: 1
          =0 {{host} does not give a party.}
          =1 {{host} invites {guest} to their party.}
          =2 {{host} invites {guest} and one other person to their party.}
          other {{host} invites {guest} and # other people to their party.}}}}",
      gender_of_host: "male", host: "kip", guest: "jim", num_guests: 4
           ) ==
             {:ok, ["kip invites jim and 3 other people to his party."]}
  end

  test "select ordinal" do
    assert Cldr.Message.format("It's my cat's {year, selectordinal,
        one {#st}
        two {#nd}
        few {#rd}
        other {#th}
    } birthday!",
             year: 3
           ) == {:ok, ["It's my cat's ", "3rd", " birthday!"]}
  end

  test "decimal selector" do
    assert Cldr.Message.format("{a, plural, =0 {zero} other {other #}}", a: Decimal.new(2)) ==
             {:ok, ["other 2"]}

    assert Cldr.Message.format("{a, plural, =0 {zero} other {other #}}", a: Decimal.new(0)) ==
             {:ok, ["zero"]}
  end

  test "plural, select and selectordinal with no other argument raises" do
    assert Cldr.Message.format("{num, plural, =0 {it's zero}}", num: 1) ==
             {:error,
              {Cldr.Message.ParseError,
               "'plural', 'select' and 'selectordinal' arguments must have an 'other' clause. Found %{0 => [literal: \"it's zero\"]}"}}

    assert Cldr.Message.format("{num, select, zero {it's zero}}", num: 1) ==
             {:error,
              {Cldr.Message.ParseError,
               "'plural', 'select' and 'selectordinal' arguments must have an 'other' clause. Found %{\"zero\" => [literal: \"it's zero\"]}"}}

    assert Cldr.Message.format("{num, selectordinal, =0 {it's zero}}", num: 1) ==
             {:error,
              {Cldr.Message.ParseError,
               "'plural', 'select' and 'selectordinal' arguments must have an 'other' clause. Found %{0 => [literal: \"it's zero\"]}"}}
  end
end
