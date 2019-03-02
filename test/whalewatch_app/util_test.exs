defmodule WhalewatchApp.UtilTest do
  use ExUnit.Case

  alias WhalewatchApp.Util

  describe "to_int/1" do
    test "returns 0 with invalid params" do
      assert Util.to_int(nil) == 0
      assert Util.to_int(0) == 0
    end

    test "returns correct amount with float" do
      assert Util.to_int(23.123) == 23
    end

    test "returns correct amount with Decimal" do
      decimal = Decimal.from_float(234.12)
      assert Util.to_int(decimal) == 234
    end

    test "returns argument if it's an int already" do
      assert Util.to_int(1000) == 1000
    end
  end

  describe "parse_value/1" do
    test "returns 0 with invalid params" do
      assert Util.parse_value(0) == 0
      assert Util.parse_value("0x") == 0
      assert Util.parse_value(nil) == 0
    end

    test "parses valid hex value" do
      assert Util.parse_value("0x6b7ae0000aa2000") == 484046800000000000
    end

    test "parses valid hex value when 0x0" do
      assert Util.parse_value("0x0") == 0
    end
  end

  describe "to_token/2" do
    test "returns 0 with invalid params" do
      assert Util.to_token(0, nil) == 0
      assert Util.to_token(nil, nil) == 0
      assert Util.to_token(0, 0) == 0
      assert Util.to_token(0, 2) == 0
      assert Util.to_token(0, -2) == 0
    end

    test "returns correct amount with valid params" do
      assert Util.to_token(484046800000000000, 18) == Decimal.from_float(0.48)
    end
  end

  describe "to_rounded/2" do
    test "returns 0 with invalid params" do
      assert Util.to_rounded(nil, nil) == 0
      assert Util.to_rounded(0, nil) == 0
    end

    test "returns rounded value with Decimal" do
      assert Util.to_rounded(Decimal.from_float(123.4432), 2) == Decimal.from_float(123.44)
    end

    test "returns rounded value with float" do
      assert Util.to_rounded(123.4432, 2) == Decimal.from_float(123.44)
    end
  end

  describe "is_eth?/1" do
    test "returns correct value with valid params" do
      assert Util.is_eth?(%{ name: "Ethereum"}) == true
      assert Util.is_eth?(%{ name: "Bitcoin"}) == false
      assert Util.is_eth?(nil) == false
      assert Util.is_eth?("") == false
    end
  end

  describe "to_cents_value/2" do
    test "returns 0 with invalid params" do
      assert Util.to_cents_value(nil, nil) == 0
      assert Util.to_cents_value(0, 0) == 0
      assert Util.to_cents_value(0, nil) == 0
      assert Util.to_cents_value(nil, 0) == 0
    end

    test "returns correct amount with valid params as Decimal" do
      assert Util.to_cents_value(Decimal.from_float(345.345), 124) == 42823
    end

    test "returns correct amount with valid params as floats" do
      assert Util.to_cents_value(345.345, 124) == 42822
    end
  end

  describe "format_value/2" do
    test "it returns 0 with invalid paramms" do
      assert Util.format_value(0) == 0
      assert Util.format_value("0x") == 0
      assert Util.format_value(nil) == 0
    end

    test "it returns formatted value with valid params" do
      assert Util.format_value("0x6b7ae0000aa2000", 18) == Decimal.from_float(0.48)
    end
  end
end 
