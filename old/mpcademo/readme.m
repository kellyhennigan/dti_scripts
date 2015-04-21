% README
% ------
%
% The demos contained in the zip file mpcademo.zip provide examples of
% application of visualization techniques in process applications. These
% demos goes together with the MathWorks News & Notes (Issue: May, 2003)
% article, titled "USING VISUALIZATION TECHNIQUES FOR BATCH CONDITION MONITORING".
% Visit: http://www.mathworks.com/company/newsletter/index.shtml
%
% This demo contains the following:
% 1. A walk-through example that explains the Multi-way PCA technique for
%    analyzing batch processes. Run WALK_THROUGH_DEMO.M in MATLAB. It makes
%    use of function COMPUTE_ELLIPSOID.M for generating some volume graphics.
%
% 2. HTML page: PROCESS_DEMO.HTML This is an html version of the
%    walk_through_demo.
%
% 3. Batch Condition Monitoring GUI: this GUI is discussed in the New &
%    Notes article. Launch this GUI by running MPCAGUI2C.M.
%    The GUI is for illustrative purposes only. By no means is this GUI the
%    best or the most efficient procedure (or even a recommended way) for
%    performing such analysis. It was put together to support the article.
%
% IMPORTANT NOTES:
% (a) After downloading and unzipping the files, please ensure that all the
% data files are writable (have full read/write permission). If not, make
% them so.
%
% (b) The graphics requires OPENGL. To check if you are using OPENGL in
% MATLAB, type: "opengl info" in command window of MATLAB.
%
% (c) How to use GUI:
%    - On left bottom corner of GUI is Analysis Data popup menu. Choose a
%      test dataset to emulate the real-life streaming data based condition
%      monitoring.
%    - The panel on the right has several useful controls. Press the "Log
%      Data" button to emulate the real-time data-logging. At each logging
%      instant, the currently forecasted regions will be drawn at the top
%      center of the GUI. The 2-D "shadows" of this 3-D plot are drawn  on
%      the three sides. 
%    - For this GUI a 5th order PCA model was used - the primary three are
%      shown on the plot, while projections along the rest two are chosen
%      from the control panel. To choose projections, drag the blue icon
%      around with your mouse, inside the ellipse. Regions outside the
%      ellipse are invalid projections. Of the 5 principal components, the
%      chosen three to be visualized can be chosen using the 3 popups for
%      X, Y and Z axes, also from the control panel.
%    - While changing the projected 3-D views by using the data panner, you
%      may want to view the locus of all such projections for different
%      choices on the panner. This can be done by clicking on the "Show
%      Trail" checkbox, located below the main 3-D view axes. Uncheck this
%      checkbox and move the icon in the panner to go back to normal view. 
%    - Control the transparency of intersecting ellipsoids by using the two
%      slider bars, located right below the 3-D view axes.
%    - Automate the data logging process by pressing the Automate button on
%      right-side control panel.
%    - Press the Time Evolution button to view an animation of the 3-D
%      score predictions at each logging time instant, until the current
%      time. This view also contains the time histories of the 12 process
%      variables, until the current time. This figure has some control
%      options that facilitate interaction, such as transparency control
%      and choosing number of ellipsoids to view.
%    - View Exterior button: By pressing this button, user can view the
%      region of intersection of score ellipsoid with in-control ellipsoid
%      separately. 
%    - RESETTING Views: This GUI is a prototype only. If at any time, you
%      get stuck and can't refresh a view, just choose a new Analysis Data
%      from the popup menu (left, bottom). You can re-select the current
%      batch also. If you are stuck real bad (with callback errors etc),
%      close the GUI and re-launch it by typing "mpcagui2c" in command
%      window. Note: OPENGL is required for volume visualization.
%    - Please take time to use Camera toolbar - lighting and view control
%      options. These tools greatly assist visualization, and also make the
%      process fun!
%
%
% If you have questions, contact me at rsingh@mathworks.com.
%
% Have fun!

disp('Please read the help contents of this m-file (>> help readme).')