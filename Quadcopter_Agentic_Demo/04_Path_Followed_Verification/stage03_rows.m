function rows = stage03_rows(series)
%STAGE03_ROWS Return logged scalar/vector signal samples as rows.
count = numel(series.Time);
if series.IsTimeFirst
    rows = reshape(series.Data, count, []);
else
    rows = reshape(series.Data, [], count)';
end
end
