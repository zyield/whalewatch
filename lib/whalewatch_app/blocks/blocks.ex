defmodule WhalewatchApp.Blocks do
  alias WhalewatchApp.{Blocks.Block, Repo}

  def list_blocks do
    Repo.all(Block)
  end

  def get(id), do: Repo.get(Block, id)

  def get_by_number(%{"number" => number}) do
    Repo.get_by(Block, number: number)
  end

  def create_block(attrs) do
    %Block{}
    |> Block.changeset(attrs)
    |> Repo.insert
  end

end
