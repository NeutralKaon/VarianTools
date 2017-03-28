function varargout = viewimage(varargin)
% VIEWIMAGE displays an image and adds a few user controls:
%   1) Right mouse button win/lev controls
%   2) Left mouse button image scrolling
%   3) Menus for zooming and win/lev choices
%   4) Choose mag, phase, real or imag display for complex data
%
% Usage: viewimage(im, 'Label',options)
%
%   where im is an array (either 2D or 3D, real or complex)
%         Label is an optional string label;
%         Options are key-value pairs chosen from: 
%           - 'colormap', 'hot' (or any other valid colormap);
%           - 'title', 'string'. 
%           - 'zoom', <a positive real number greater than 0>. 
%
%         Note that having an odd-number of arguments will _not_ work
%         (I.e., don't do viewimage(a, 'Title', 'Colormap','hot')...
%         ...do viewimage(a,'title','Title','Colormap','Hot') instead).
%
%
% Modified by Jack Miller & Angus Lau 


% Some versions of matlab may need to uncomment the below: 
%warning('off','all')
%feature('usehg2',0);
%warning('on','all')
global ImageTag;
if ischar(varargin{1})
    % If first argument passed is a character string, invoke callback routines
    try
        if (nargout)
            [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
        else
            feval(varargin{:}); % FEVAL switchyard
        end
    catch ME
        %disp(ME.identifier);
        disp(ME.message);
        disp(ME.cause);
    end
else
    % Otherwise, open a new figure and post the image
    % For complex data, use the magnitude
    if nargin==2
        if ischar( varargin{2} )
            ImageTag = varargin{2};
        else
            fprintf('Please see help viewimage.\n');
        end
    else
        ImageTag = 'MyImage';
    end
    imstack    = squeeze(varargin{1});
    
    %JM -- parse additional inputs, currently just a default colormap,
    %figure title, and zoom:
    
    changeSomething=false;
    if (length(varargin) ~= 2)
        p=inputParser;
        defaultColormap='gray';
        expectedColormaps={'jet','gray','hot','hsv','cool','spring','summer','autumn','winter','bone','copper','pink'};
        
        defaultTitle=inputname(1);
        
        defaultZoom='';
        
        defaultColorbar=false; 
        expectedColorbars={'true','false'};
        
        addOptional(p,'colormap',defaultColormap,@(x) any(validatestring(x,expectedColormaps)));
        addOptional(p,'title',defaultTitle,@ischar);
        addOptional(p,'colorbar',defaultColorbar,@(x) any(validatestring(x,expectedColorbars)));
        addOptional(p,'zoom',defaultZoom)
        
        parse(p,varargin{2:end});
        
        usedColormap=p.Results.colormap;
        useColorbar=strcmp(p.Results.colorbar,'true');
        usedZoom=p.Results.zoom; 
        
        if isempty(usedZoom)
            zoomOnStartup=false;
        else
            zoomOnStartup=true;
            zoomOnStartupLevel=num2str(usedZoom);
        end
        
        ImageTag=p.Results.title;
        if isempty(ImageTag)
            ImageTag='MyImage';
        end
        changeSomething=true;
    end
    
    
    % AZL 18.02.2013
    % restrict imstack to 3D
    if (ndims(imstack)>3)
        imstack = imstack(:,:,1:size(imstack,3));
    end
    
    num_images = size(imstack,3);
    xres       = size(imstack,2);
    yres       = size(imstack,1);
    cmplxdata  = ~isreal(imstack);
    
    % Create the figure graphics object, set the basic characteristics
    
    % JJM
    % Detect primary monitor
    monitorPos = get(0,'MonitorPositions');
    monitorPri = monitorPos(1,:);
    monitorPri = monitorPri + [monitorPri(3)*0.10 monitorPri(4)*0.10 -monitorPri(3)*0.10 -monitorPri(4)*0.10];
    
    % AZL Jul-08-2009 changed toolbar to figure from 'none'
    hfig = figure(  'Tag', 'MyFigure', 'Toolbar', 'figure', ...
        'Resize', 'on', 'NumberTitle', 'off', ...
        'Name', sprintf('Viewimage: %s', ImageTag), ...
        'Colormap', gray(256), ...
        'DoubleBuffer', 'on', ...
        'Position', [monitorPri([1 2]) xres yres] );

    
    
    % Set up the callbacks for right mouse button Win/Lev controls
    set( hfig, 'WindowButtonDownFcn',   'viewimage(''Press'', gcf, gca)' );
    set( hfig, 'WindowButtonUpFcn',     'viewimage(''Release'', gcf, gca)' );
    
    % JJM - 27-10-14 - Modified to mousewheel through images 
    set( hfig, 'WindowScrollWheelFcn', @Scroll);
    
    % Hide the View, Insert, Tools, Window, and Help menus in the figure
    set(0, 'ShowHiddenHandles', 'on');
    set( findobj( hfig, 'Tag',   'figMenuView'  ), 'Visible', 'off');
    set( findobj( hfig, 'Tag',   'figMenuInsert'), 'Visible', 'off');
    set( findobj( hfig, 'Tag',   'figMenuTools' ), 'Visible', 'off');
    set( findobj( hfig, 'Label', '&Window'      ), 'Visible', 'off');
    set( findobj( hfig, 'Label', '&Help'        ), 'Visible', 'off');
    set(0, 'ShowHiddenHandles', 'off')
    
    % Add ZOOM menu with some sensible defaults 
    hmenu1 = uimenu( hfig, 'Label','Zoom');
    uimenu(hmenu1, 'Label', '1X', 'Callback', 'viewimage(''zoomit'', gcf, gca, 1)', ...
        'Checked', 'on' );
    uimenu(hmenu1, 'Label', '2X', 'Callback', 'viewimage(''zoomit'', gcf, gca, 2)' );
    uimenu(hmenu1, 'Label', '3X', 'Callback', 'viewimage(''zoomit'', gcf, gca, 3)' );
    uimenu(hmenu1, 'Label', '4X', 'Callback', 'viewimage(''zoomit'', gcf, gca, 4)' );
    uimenu(hmenu1, 'Label', '6X', 'Callback', 'viewimage(''zoomit'', gcf, gca, 6)' );
    uimenu(hmenu1, 'Label', '8X', 'Callback', 'viewimage(''zoomit'', gcf, gca, 8)' );
    
    % Add WINDOW/LEVEL menu
    hmenu2 = uimenu( hfig, 'Label','W/L');
    uimenu(hmenu2, 'Label', 'AutoW/L', 'Tag', 'AutoWL', 'Checked', 'on', 'Callback', 'viewimage(''autowl'', gcf, gca)' );
    uimenu(hmenu2, 'Label', 'To Workspace', 'Callback',   'viewimage(''wl_to_ws'', gcf, gca)' );
    uimenu(hmenu2, 'Label', 'From Workspace', 'Callback',   'viewimage(''wl_from_ws'', gcf, gca)' );
    
    % Add PLOT menu
    hmenu3 = uimenu( hfig, 'Label','Plot');
    uimenu(hmenu3, 'Label', 'Plot Row', 'Callback',   'viewimage(''plot_rc'', gcf, gca, 2)' );
    uimenu(hmenu3, 'Label', 'Plot Column', 'Callback',   'viewimage(''plot_rc'', gcf, gca, 1)' );
    if num_images > 1
        uimenu(hmenu3, 'Label', 'Plot Through', 'Callback', 'viewimage(''plot_through'', gcf, gca)' );
        uimenu(hmenu3, 'Label', 'Plot ROI Through', 'Callback', 'viewimage(''plot_roi_through'', gcf, gca)' );
    end
    
    % Add COMPLEX menu
    hmenu0 = uimenu( hfig, 'Label','Complex', 'Tag', 'cmplx_menu', 'Enable', 'off');
    if cmplxdata
        set( hmenu0, 'Enable', 'on');
        uimenu(hmenu0, 'Label', 'Magn.', 'Checked', 'on', 'Callback', 'viewimage(''disptype'', gcf, gca, 1)' );
        uimenu(hmenu0, 'Label', 'Phase', 'Callback', 'viewimage(''disptype'', gcf, gca, 2)' );
        uimenu(hmenu0, 'Label', 'Real',  'Callback', 'viewimage(''disptype'', gcf, gca, 3)' );
        uimenu(hmenu0, 'Label', 'Imag',  'Callback', 'viewimage(''disptype'', gcf, gca, 4)' );
    end
    
    % Add MATH menu
    roi_exist = 0;
    
    hmenu4 = uimenu( hfig, 'Label', 'Math' );
    uimenu(hmenu4, 'Label', 'Signal ROI', 'Callback', 'viewimage(''get_roi'', 1)' );
    uimenu(hmenu4, 'Label', 'Noise ROI', 'Callback', 'viewimage(''get_roi'', 2)' );
    %uimenu(hmenu4, 'Separator', 'on' );
    uimenu(hmenu4, 'Label', 'Calc SNR', 'Callback', 'viewimage(''calc_snr'',gca,roi1,roi2)');
    
    hmenu5 = uimenu( hfig, 'Label', 'Colormap' );
    uimenu(hmenu5, 'Label', 'Gray', 'Callback', 'viewimage(''set_colormap'', gcf, ''gray'')' );
    uimenu(hmenu5, 'Label', 'Jet',  'Callback', 'viewimage(''set_colormap'', gcf, ''jet'')' );
    uimenu(hmenu5, 'Label', 'Hot',  'Callback', 'viewimage(''set_colormap'', gcf, ''hot'')' );
    
    % Create the axes graphics object
    axes_UD.num   = 1;
    axes_UD.count = num_images;
    axes_UD.cmplx = cmplxdata;		% 0 if real, 1-4 if cmplx
    haxes = axes(   'Tag', 'MyAxes', ...
        'Position', [ 0 0 1 1], ...
        'Visible', 'off', ...
        'CLimMode', 'auto', ...
        'Xlim', [1-.5 xres+.5], 'Ylim', [1-.5 yres+.5], ...
        'YDir', 'reverse' );
    
    % Create the image graphics object
    if cmplxdata==0
        im = imstack(:,:,1);
    else
        im = abs(double(imstack(:,:,1)));
    end
    himage = image( 'Tag', ImageTag, 'CData', im, 'UserData', imstack, ...
        'CDataMapping', 'scaled');
    if verLessThan('matlab','8.4.0'); 
    else
        setappdata(hfig.Number,'CData',im); 
        setappdata(hfig.Number,'UserData',imstack);
    end 
    
    axes_UD.himage = himage;
    set( haxes, 'UserData', axes_UD );
    
    if changeSomething
        colormap(usedColormap);
        if useColorbar
            colorbar('peer',haxes);
        end
    end
    
    if zoomOnStartup
        eval(['viewimage(''zoomit'', gcf, gca, ',zoomOnStartupLevel,')']);
    end
    movegui(gcf,'onscreen');
    
    
    %If you uncommented the things at the begining, you probably want to re-enable hg2 later. 
    %feature('usehg2',1);
end


%=======================================================================
% CALLBACK  and support functions
%=======================================================================

% Zoom menu functions
% ----------------------------------------------------------
function varargout = zoomit( hfig, haxes, zoomval, varargin)
global ImageTag;
himage      = findobj( haxes, 'Tag', ImageTag);
xdata = get( himage, 'XData');
ydata = get( himage, 'YData');
xres = xdata(2)-xdata(1)+1;
yres = ydata(2)-ydata(1)+1;

position = get(hfig, 'Position');
upper_edge = position(2)+position(4);
position(3) = xres*zoomval;
position(4) = yres*zoomval;
position(2) = upper_edge - position(4);
set(hfig, 'Position', position);
autocheckmark( gcbo );

% Menu based W/L functions
% ---------------------------------------------------------------
function varargout = autowl( hfig, haxes, varargin)
h_autowl = findobj( hfig, 'Tag', 'AutoWL');
switch get( h_autowl, 'Checked')
    case 'on'
        set( h_autowl, 'Checked', 'off');
        set( haxes, 'CLimMode', 'manual');
    case 'off'
        set( h_autowl, 'Checked', 'on');
        set( haxes, 'CLimMode', 'auto');
        viewimage( 'update_wl', hfig, haxes);
end


function varargout = wl_to_ws( hfig, haxes, varargin)
lims = get(haxes, 'CLim');
win = lims(2)-lims(1);
lev = (lims(1)+lims(2))/2;
assignin( 'base', 'win', win);
assignin( 'base', 'lev', lev);

function varargout = wl_from_ws( hfig, haxes, varargin)
win = evalin( 'base', 'win');
lev = evalin( 'base', 'lev');
set(haxes, 'CLim', [lev-win/2 lev+win/2]);
viewimage( 'update_wl', hfig, haxes);

% Mouse based W/L and image scroll functions
% -----------------------------------------------------------------------
function varargout = Press(hfig, haxes, varargin)
set( hfig, 'WindowButtonMotionFcn', 'viewimage(''Move'', gcf, gca, 0)' );
viewimage('Move', gcf, gca, 1);     % Store initial mouse pointer location by calling 'Move' routine

% Scrollwheel function 
% -----------------------------------------------------------------------
function varargout = Scroll(object, event) 

viewimage('DoScroll',gcf,gca,event.VerticalScrollCount);

function varargout = DoScroll(hfig, haxes, sc, varargin)
persistent LASTX LASTY MOVED 
ptr=get(hfig, 'CurrentPoint'); 
        LASTX = ptr(1); 
        LASTY = ptr(2); 

   dx=ptr(1)-LASTX; 
  dy=sc; 
   
   axes_UD     = get( haxes, 'UserData');
   himage      = axes_UD.himage;
   imstack     = get( himage,'UserData');
   cmplx_disp  = axes_UD.cmplx;
   im_num      = axes_UD.num;
   nimages     = axes_UD.count;
   new_im_num  = im_num - dy;
   new_im_num  = max(new_im_num,1);
   new_im_num  = min(new_im_num, nimages);
   axes_UD.num = new_im_num;
   set( hfig,  'Name', sprintf('Viewimage: Im# %d/%d', axes_UD.num, axes_UD.count ));
   set( haxes, 'UserData', axes_UD );
   viewimage( 'update_image', hfig, haxes, himage);

% Callback to do nothing on mouse release 
% --------------------
function varargout = Release(hfig, haxes, varargin)
set( hfig, 'WindowButtonMotionFcn', '' );    % This makes the callback a do-nothing operation
if verLessThan('matlab','8.4.0')
    axes_UD     = get( haxes, 'UserData');
    ImageTag = get( axes_UD.himage, 'Tag' );
    set( hfig, 'Name', sprintf('Viewimage: %s', ImageTag) );

else
    global ImageTag;
    set( hfig, 'Name', sprintf('Viewimage: %s', ImageTag) );

end

function varargout = Move(hfig, haxes, init, varargin)
persistent LASTX LASTY MOVED
ptr = get(hfig,  'CurrentPoint');
if init == 1
    LASTX = ptr(1);
    LASTY = ptr(2);
    
else
    dx = ptr(1)-LASTX;
    dy = ptr(2)-LASTY;
    
    switch get(hfig,  'SelectionType');
        
        case 'normal'    % Mouse moved with LEFT button pressed -- scroll thru images
            axes_UD     = get( haxes, 'UserData');
            himage      = axes_UD.himage;
            imstack     = get( himage,'UserData');
            cmplx_disp  = axes_UD.cmplx;
            im_num      = axes_UD.num;
            nimages     = axes_UD.count;
            new_im_num  = im_num - dy;
            new_im_num  = max(new_im_num,1);
            new_im_num  = min(new_im_num, nimages);
            axes_UD.num = new_im_num;
            set( hfig,  'Name', sprintf('Viewimage: Im# %d/%d', axes_UD.num, axes_UD.count ));
            set( haxes, 'UserData', axes_UD );
            viewimage( 'update_image', hfig, haxes, himage);
            
        case 'alt'    % Mouse moved with RIGHT button pressed -- change W/L
            clims = get( haxes, 'CLim');
            win = clims(2)-clims(1);
            lev = (clims(1)+clims(2))/2;
            newwin = win * 10^(dx/400);
            newlev = lev - (win*dy)/200;
            set(haxes, 'CLim', [newlev-newwin/2 newlev+newwin/2]);
            set( findobj( hfig, 'Tag', 'AutoWL'), 'Checked', 'off');
            viewimage( 'update_wl', hfig, haxes);
            
    end
    LASTX = ptr(1);
    LASTY = ptr(2);
end

% Repaint the image
% ----------------------------------------------------
function varargout = update_image( hfig, haxes, himage, varargin)
axes_UD = get( haxes, 'UserData');
im_num = axes_UD.num;
disp_type = axes_UD.cmplx;

imstack     = get( himage,'UserData');
im = double(imstack(:,:,im_num));
switch disp_type
    case 1
        im = abs(im);
    case 2
        im = angle(im);
    case 3
        im = real(im);
    case 4
        im = imag(im);
end
set( himage,'CData', im);

% Update the W/L display
% -----------------------------
function varargout = update_wl( hfig, haxes, varargin)
clims = get( haxes, 'CLim');
set( hfig, 'Name', sprintf('Viewimage W:%.3g L:%+.3g', ...
    clims(2)-clims(1), (clims(1)+clims(2))/2 ));

% Select display type (magnitude, phase, real, or imag)
% -----------------------------------------------------
function varargout = disptype( hfig, haxes, disp_type, varargin)
axes_UD = get( haxes, 'Userdata');
axes_UD.cmplx = disp_type;
set( haxes, 'Userdata', axes_UD);
himage      = findobj( haxes, 'Tag', 'MyImage');
viewimage( 'update_image', hfig, haxes, himage);
viewimage( 'update_wl', hfig, haxes);
autocheckmark( gcbo );

% Menu based Colormap functions
% ---------------------------------------------------------------
% AZL 11.02.2013
function varargout = set_colormap( hfig, map, varargin )
switch map
    case 'gray'
        cmap = gray(256);
    case 'jet'
        cmap = jet(256);
    case 'hot'
        cmap = hot(256);
end
set(hfig, 'Colormap', cmap);

% Menu based Math functions
% ---------------------------------------------------------------
function varargout = get_roi( roi_val, varargin)
%roi = roipoly;
roi_free = imfreehand;
roi = roi_free.createMask();
assignin( 'base', strcat(['roi' num2str(roi_val)]), roi);

function varargout = calc_snr( haxes, roi1, roi2, varargin )
axes_UD = get( haxes, 'UserData');
im_num = axes_UD.num;
disp_type = axes_UD.cmplx;
himage = axes_UD.himage;
imstack = get( himage,'UserData');
im = double(imstack(:,:,im_num));
switch disp_type
    case 1
        im = abs(im);
    case 2
        im = angle(im);
    case 3
        im = real(im);
    case 4
        im = imag(im);
end

s = abs(mean(im(roi1)));
n = abs(std(im(roi2)));
snr = s/n;

assignin( 'base', 'snr', snr);

disp(sprintf('------------------'));
disp(sprintf('signal = %.4f',s));
disp(sprintf('noise  = %.4f',n));
disp(sprintf('snr    = %.4f',snr));
disp(sprintf('------------------'));

% Automatic checkmarks for menu items: checkmark the 'hitem', uncheck the others
% ------------------------------------------------------------------------------
function varargout = autocheckmark( hitem,  varargin)
hmenu     = get( hitem, 'Parent' );
hchildren = get( hmenu, 'Children');
for i = 1:length(hchildren)
    set( hchildren(i), 'Checked', 'off');    % Uncheck all the menu items
end
set( hitem, 'Checked', 'on');    % Check the menu item that made the callback

% Plot a row of column of data from the image
% ----------------------------------------------------
function varargout = plot_rc( hfig, haxes, direction, varargin)
[x, y] = ginput(1);
x = round(x);
y = round(y);
if verLessThan('matlab','8.4.0')
    himage      = findobj( haxes, 'Tag', 'MyImage');
    im = get(himage, 'CData');
else
    im = getappdata(hfig,'CData');
end
figure;
switch direction
    case 2
        plot( im(round(y),:) );
        title(sprintf('Row %d', y));
    case 1
        plot( im(:,round(x)) );
        title(sprintf('Column %d', x));
end

% Plot through-plane data from the image
% ----------------------------------------------------
function varargout = plot_through( hfig, haxes, varargin)

[x, y] = ginput(1);
x = round(x);
y = round(y);

axes_UD = get( haxes, 'UserData');
himage  = axes_UD.himage;
imstack = get( himage,'UserData');

disp_type = axes_UD.cmplx;

switch disp_type
    case 1
        imstack = abs(imstack);
    case 2
        imstack = angle(imstack);
    case 3
        imstack = real(imstack);
    case 4
        imstack = imag(imstack);
end

figure;

plot( squeeze(imstack(y,x,:)), '.-' );
ylabel(sprintf('Magnitude at (%d, %d)', x, y));

% Draw an ROI and plot it through the image 
% ----------------------------------------------------
function varargout = plot_roi_through( hfig, haxes, varargin)

mask=roipoly();

axes_UD = get( haxes, 'UserData');
if verLessThan('matlab','8.5.0');
    himage  = axes_UD.himage;
    imstack = get( himage,'UserData');
else
    imstack=getappdata(hfig,'UserData');
end

disp_type = axes_UD.cmplx;

switch disp_type
    case 1
        imstack = abs(imstack);
    case 2
        imstack = angle(imstack);
    case 3
        imstack = real(imstack);
    case 4
        imstack = imag(imstack);
end

figure;
mask=repmat(mask, [1,1, size(imstack, 3)]);
plot( squeeze(sum(sum(mask.*imstack))./sum(sum(mask))), '.-' );
ylabel('ROI Magnitude/Mask size');
%---------------------------------------------------------------
% Again, the below might be required on some versions of matlab 


% function im=getImage(haxes)
% %Required helper function for HG2 graphics 
% try
%     hg1=graphicsversion('handlegraphics'); 
% catch
%     hg1=99;
% end
% 
% if ~hg1
%     
% else %Old graphics
%     himage      = findobj( haxes, 'Tag', 'MyImage');
%     im= get(himage, 'CData');
% end
