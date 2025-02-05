function trapez()

x_limit_low = 0;
x_limit_high = 5;
x_num_steps_min = 2;
x_num_steps_max = 100;
real_area = integral((@(x) x.^2), x_limit_low, x_limit_high);

log_base=3;
log_min = log(x_num_steps_min)/log(log_base);
log_max = log(x_num_steps_max)/log(log_base);

x_num_steps_initial = (log_max+log_min)/2;


figure('Name', 'Interaktivna integracija');
ax = axes;

%slider
s_width = 0.6;
s_pos = [(1 - s_width)/2, 0.05, s_width, 0.05];
slider = uicontrol('Style', 'slider',...
    'Min', log_min, 'Max', log_max,...
    'Value', x_num_steps_initial,...
    'Units', 'normalized', 'Position', s_pos);
slider.Callback = @(source,event) update_plot(ax, source, x_limit_low, x_limit_high, real_area, log_base);

% gumbovi + -
b_width = 0.1;
b_height = 0.05;

subtract_button = uicontrol('Style', 'pushbutton',...
        'String', '-',...
        'Units', 'normalized',...
        'Position', [s_pos(1) - b_width, 0.05, b_width, b_height],...
        'Callback', @(source,event) adjust_steps(slider, -1, x_num_steps_min, x_num_steps_max, ax, x_limit_low, x_limit_high, real_area, log_base));
add_button = uicontrol('Style', 'pushbutton',...
        'String', '+',...
        'Units', 'normalized',...
        'Position', [s_pos(1) + s_width, 0.05, b_width, b_height],...
        'Callback', @(source,event) adjust_steps(slider, 1, x_num_steps_min, x_num_steps_max, ax, x_limit_low, x_limit_high, real_area, log_base));

    function adjust_steps(slider, step_change, x_num_steps_min, x_num_steps_max, ax, x_limit_low, x_limit_high, real_area, log_base)
        log_steps = get(slider, 'Value');
        current_steps = log_base^log_steps;

        new_steps = round(current_steps + step_change);

        % Keep within min/max limits
        new_steps = max(x_num_steps_min, min(x_num_steps_max, new_steps));

        log_steps = log(new_steps)/log(log_base);
        set(slider, 'Value', log_steps);
        update_plot(ax, slider, x_limit_low, x_limit_high, real_area, log_base);
    end


% početna slika
update_plot(ax, slider, x_limit_low, x_limit_high, real_area, log_base);


    function update_plot(ax, source, x_limit_low, x_limit_high, real_area, log_base)
    log_val = get(source,'Value'); % 0 - logbase(maxstep)
    x_num_steps = round(log_base^log_val);
    set(source,'Value', (log(x_num_steps)/log(log_base)));


    x_step_diff = (x_limit_high-x_limit_low)/x_num_steps;
    x = x_limit_low : x_step_diff : x_limit_high;
    y = x.^2;

    cla(ax);  % Očisti staru sliku!!

    fplot(ax, @(x) x.^2, [x_limit_low, x_limit_high], 'Color', 'b', 'LineWidth', 1); % prava krivulja
    hold(ax, 'on');

    p = area(x,y, 'Parent', ax);
    grid(ax);

    p.FaceColor = "#dba5f2";
    p.FaceAlpha = 0.2;
    p.LineWidth = 2;

    avg_y = y(1:length(x)-1) + diff(y)/2;
    A = sum(diff(x) .* avg_y);

    
    for i = 1:length(x)
        plot(ax, [x(i), x(i)], [0, y(i)], 'Color', "#122c6e", 'LineWidth', 2);
    end
    hold(ax, 'off');

    text(ax, 0.05*(x_limit_high-x_limit_low), 0.9*max(y),  sprintf('%*s%.8g', 17, 'Površina = ', A),               'FontName', 'Courier New', 'FontSize', 12, 'BackgroundColor', 'w');
    text(ax, 0.05*(x_limit_high-x_limit_low), 0.85*max(y), sprintf('%*s%.8g', 17, 'Točna površina = ', real_area), 'FontName', 'Courier New', 'FontSize', 12, 'BackgroundColor', 'w');
    text(ax, 0.05*(x_limit_high-x_limit_low), 0.8*max(y),  sprintf('%*s%d', 17,   'broj trapeza = ', x_num_steps), 'FontName', 'Courier New', 'FontSize', 12, 'BackgroundColor', 'w');
   
end



end