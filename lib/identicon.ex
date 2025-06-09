defmodule Identicon do
  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  defp pick_color(image) do
    %Identicon.Image{hex: [red, green, blue | _tail]} = image

    %Identicon.Image{image | color: {red, green, blue}}
  end

  defp save_image(image, input) do
    File.write("#{input}.png", image)
  end

  defp draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    pixel_map |> Enum.each(fn {start, stop} -> :egd.filledRectangle(image, start, stop, fill) end)
    :egd.render(image)
  end

  defp build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map =
      Enum.map(grid, fn {_code, index} ->
        horizontal = rem(index, 5) * 50
        vertical = div(index, 5) * 50

        top_left = {horizontal, vertical}
        bottom_right = {horizontal + 50, vertical + 50}

        {top_left, bottom_right}
      end)

    %Identicon.Image{image | pixel_map: pixel_map}
  end

  defp filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    grid = grid |> Enum.filter(fn {value, _index} -> rem(value, 2) === 0 end)
    %Identicon.Image{image | grid: grid}
  end

  defp build_grid(%Identicon.Image{hex: hex} = image) do
    hex =
      Enum.chunk_every(hex, 3)
      |> Enum.map(&mirror_rows/1)
      |> List.flatten()
      |> Enum.with_index()

    %Identicon.Image{image | grid: hex}
  end

  defp mirror_rows([first, second | _tail] = row) do
    row ++ [second, first]
  end

  defp hash_input(input) do
    hex = :crypto.hash(:md5, input) |> Base.encode16() |> :binary.bin_to_list()
    %Identicon.Image{hex: hex}
  end
end
