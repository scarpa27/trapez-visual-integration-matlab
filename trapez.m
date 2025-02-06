function trapez(f_string, g_string, varargin)


if isempty(f_string)
    f_string = 'x.^2';
end
if isempty(g_string)
    g_string = '-x.^2 +4';
end

x_limit_low = 0;
x_limit_high = 5;
x_num_steps_min = 2;
x_num_steps_max = 100;

if length(varargin) == 2
    x_limit_low = varargin{1};
    x_limit_high = varargin{2};
end


s = sym('s');
x_axis = @(x) 0;
fun = str2func(append('@(x) ', f_string));
gun = str2func(append('@(x) ', g_string));

ra_fun = str2func(append('@(s) ', replace(f_string, 'x', 's') ));
ra_gun = str2func(append('@(s) ', replace(g_string, 'x', 's') ));

real_area = get_real_area(ra_fun, ra_gun);

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
slider.Callback = @(source,event) update_plot(fun, gun, ax, source, x_limit_low, x_limit_high, real_area, log_base);

% gumbovi + -
b_width = 0.1;
b_height = 0.05;

uicontrol('Style', 'pushbutton',...
        'String', '-',...
        'Units', 'normalized',...
        'Position', [s_pos(1) - b_width, 0.05, b_width, b_height],...
        'Callback', @(source,event) adjust_steps(fun, gun, slider, -1, x_num_steps_min, x_num_steps_max, ax, x_limit_low, x_limit_high, real_area, log_base));
uicontrol('Style', 'pushbutton',...
        'String', '+',...
        'Units', 'normalized',...
        'Position', [s_pos(1) + s_width, 0.05, b_width, b_height],...
        'Callback', @(source,event) adjust_steps(fun, gun, slider, 1, x_num_steps_min, x_num_steps_max, ax, x_limit_low, x_limit_high, real_area, log_base));

    function adjust_steps(fun, gun, slider, step_change, x_num_steps_min, x_num_steps_max, ax, x_limit_low, x_limit_high, real_area, log_base)
        log_steps = get(slider, 'Value');
        current_steps = log_base^log_steps;

        new_steps = round(current_steps + step_change);

        % Keep within min/max limits
        new_steps = max(x_num_steps_min, min(x_num_steps_max, new_steps));

        log_steps = log(new_steps)/log(log_base);
        set(slider, 'Value', log_steps);
        update_plot(fun, gun, ax, slider, x_limit_low, x_limit_high, real_area, log_base);
    end


% početna slika
update_plot(fun, gun, ax, slider, x_limit_low, x_limit_high, real_area, log_base);


    function update_plot(fun, gun, ax, source, x_limit_low, x_limit_high, real_area, log_base)
    log_val = get(source,'Value'); % 0 - logbase(maxstep)
    x_num_steps = round(log_base^log_val);
    set(source,'Value', (log(x_num_steps)/log(log_base)));


    x_step_diff = (x_limit_high-x_limit_low)/x_num_steps;
    x = x_limit_low : x_step_diff : x_limit_high;
    y = fun(x)-gun(x);
    yf = fun(x);
    yg = gun(x);

    [yf, yg] = adj_vct_size(yf, yg);

    cla(ax);  % Očisti staru sliku!!

    fplot(ax, fun, [x_limit_low, x_limit_high], 'Color', 'b', 'LineWidth', 1); % prava krivulja
    hold(ax, 'on');
    fplot(ax, gun, [x_limit_low, x_limit_high], 'Color', 'r', 'LineWidth', 1); % prava krivulja

    pf = area(x,yf, 'Parent', ax);
    pg = area(x,yg, 'Parent', ax);
    grid(ax);

    pf.FaceColor = "#dba5f2";
    pf.FaceAlpha = 0.2;
    pf.LineWidth = 2;
    pg.FaceColor = "#dba5f2";
    pg.FaceAlpha = 0.2;
    pg.LineWidth = 2;

    avg_y = y(1:length(x)-1) + diff(y)/2;
    A = sum(diff(x) .* abs(avg_y));

    
    for i = 1:length(x)
        plot(ax, [x(i), x(i)], [min(yf(i)), max(yg(i))], 'Color', "#122c6e", 'LineWidth', 2);
    end
    hold(ax, 'off');

    text(ax, -0.05, 0.8,  sprintf('%*s%.8g', 17, 'Površina = ', A),               'FontName', 'Courier New', 'FontSize', 12, 'BackgroundColor', 'w', 'Units', 'Normalized');
    text(ax, -0.05, 0.75, sprintf('%*s%.8g', 17, 'Točna površina = ', real_area), 'FontName', 'Courier New', 'FontSize', 12, 'BackgroundColor', 'w', 'Units', 'Normalized');
    text(ax, -0.05, 0.7,  sprintf('%*s%d', 17,   'broj trapeza = ', x_num_steps), 'FontName', 'Courier New', 'FontSize', 12, 'BackgroundColor', 'w', 'Units', 'Normalized');
   
    end

    function area = get_real_area (f, g)
        area = 0;

        r = sort(solve(f(s) == g(s), s));
        r = [x_limit_low, r', x_limit_high]
        r = r(imag(r)==0)
        r = r(r >= x_limit_low & r <= x_limit_high);
        r = double(r);

        for i = 1 : length(r)-1
            a = integral(@(s) abs(f(s) - g(s)), r(i), r(i+1));
            area = area + a;
        end
    end

    function [v1, v2] = adj_vct_size(a, b)
        sa = length(a);
        sb = length(b);

        v1 = a;
        v2 = b;
        if (sa < sb && sa == 1) || (sb < sa && sb == 1)
            if sa < sb  % vector1 is smaller and of size 1
                v1 = repmat(a, 1, sb);
            else
                v2 = repmat(b, 1, sa);
            end
         end
    end



end