function varargout = sharedWorkspace(ws, varargin)
% SHAREDWORKSPACE  Set and retrieve variables from a shared workspace
% Usage:
%   sharedWorkspace('ws', '-clear')
%   sharedWorkspace('ws', S)
%   S = sharedWorkspace('ws')
%   sharedWorkspace('ws', 'var', val)
%   val = sharedWorkspace('ws', 'var')
%   tf = sharedWorkspace('ws', '-exist')
%   tf = sharedWorkspace('ws', '-exist', 'var')
%   wsNames = sharedWorkspace
%   clear sharedWorkspace
% A shared workspace is useful for sharing information between multiple
% functions that are intended to work in concert for a complex task (eg.,
% running a realtime experiment) without the messiness of passing extra
% variables around or the hazards of global variables.
%
%   sharedWorkspace('ws', '-clear')
%   sharedWorkspace ws -clear
%     These two equivalent usages establish a new shared workspace named
%     'ws'. It is not necessary to call this version of the function to
%     begin using a shared workspace, but doing so clears all data that
%     might still be in the workspace, which is good practice.
%   sharedWorkspace('ws', S)
%     This usage clears all variables in the shared workspace and replaces
%     them with the fields in the struct S.  Eg, if S has the fields x and
%     y, then the workspace 'ws' will have two variables, x and y, taking
%     their values from S.
%   S = sharedWorkspace('ws')
%     This usage returns a struct with fields set by the variables present
%     in the shared workspace 'ws'. Eg., if 'ws' has variables x and y, S
%     will have two fields, x and y, taking their values from 'ws'.
%   sharedWorkspace('ws', 'var', val)
%     This usage sets the variable 'var' in the shared workspace 'ws' to
%     the value val. 'var' does not need to be predefined.
%   val = sharedWorkspace('ws', 'var')
%     This usage retrieves the value of the variable 'var'.  If 'var' is
%     not set, an error occurs.
%   tf = sharedWorkspace('ws', '-exist')
%     This usage checks to see if the shared workspace 'ws' exists.
%   tf = sharedWorkspace('ws', '-exist', 'var')
%     This usage checks to see if the variable 'var' exists in the
%     workspace 'ws'. Returns true or false.
%   clear sharedWorkspace
%     This call to CLEAR will clear all shared workspaces. Good for freeing
%     up memory, but use with caution.

persistent SWS
if isempty(SWS)
    SWS = struct;
end

if nargin == 0
    varargout{1} = fieldnames(SWS);
elseif nargin == 1
    varargout{1} = SWS.(ws);
elseif nargin == 2
    if isstruct(varargin{1})
        SWS.(ws) = varargin{1};
    elseif ischar(varargin{1})
        switch varargin{1}
            case '-clear'
                SWS.(ws) = struct;
            case '-exist'
                varargout{1} = isfield(SWS, ws);
            otherwise
                varargout{1} = SWS.(ws).(varargin{1});
        end
    else
        % error
    end
elseif nargin == 3
    switch varargin{1}
        case '-exist'
            varargout{1} = isfield(SWS.(ws), varargin{2});
        otherwise
            SWS.(ws).(varargin{1}) = varargin{2};
    end
end
