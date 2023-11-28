require 'gnuplot'

# Example time series data with dates only
time_series = [
  ['2023-01-01', 10],
  ['2023-01-02', 15],
  ['2023-01-03', 20],
  # Add more data points as needed
]

# Extract dates and values
dates, values = time_series.transpose

# Plotting the time series with only dates
Gnuplot.open do |gp|
  Gnuplot::Plot.new(gp) do |plot|
    plot.title 'Time Series Plot'
    plot.xlabel 'Date'
    plot.ylabel 'Values'
    plot.xdata 'time'
    plot.timefmt '"%Y-%m-%d"'
    plot.format 'x "%Y-%m-%d"'

    plot.data << Gnuplot::DataSet.new([dates, values]) do |ds|
      ds.with = 'linespoints'
      ds.title = 'Time Series Data'
    end
  end
end
