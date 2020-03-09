function H = plot_1_line_w_marker_interval(x,y,styles,interval,varargin)

linestyle = styles(1:end-1);
markerstyle = styles(end);

plot(x,y,linestyle,varargin{:});
hold on;
plot(x(1:interval:end),y(1:interval:end),markerstyle,varargin{:});
H = plot(x,y,styles,'visible','off',varargin{:});
