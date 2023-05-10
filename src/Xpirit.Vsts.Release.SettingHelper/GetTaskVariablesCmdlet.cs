using System.Management.Automation;
using Microsoft.TeamFoundation.DistributedTask.Task.LegacySDK;

namespace Xpirit.Vsts.Release.SettingHelper
{
    [Cmdlet("Get", "TaskVariables")]
    public sealed class GetTaskVariablesCmdlet : PSCmdlet
    {
        [Parameter(Mandatory = true, Position = 1)]
        public ITaskContext Context { get; set; }

        [Parameter(Mandatory = false, Position = 3)]
        public bool IsSafe { get; set; }

        protected override void ProcessRecord()
        {
            base.ProcessRecord();
            
            WriteObject(TaskContextHelper.GetAllVariables(Context, IsSafe));
        }
    }
}
