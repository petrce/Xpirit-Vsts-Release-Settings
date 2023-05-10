using System.Collections.Generic;
using Microsoft.TeamFoundation.DistributedTask.Task.LegacySDK;

namespace Xpirit.Vsts.Release.SettingHelper
{
    public static class TaskContextHelper
    {
        public static IDictionary<string, string> GetAllVariables(ITaskContext context, bool isSafe = false)
        {
            var variableService = context.GetService<IVariableService>();
            var dictionary = new Dictionary<string, string>();
            if (variableService != null)
                if (!isSafe)
                    variableService.MergeVariables(dictionary);
                else
                    variableService.MergeVariables(dictionary);

            return dictionary;
        }
    }
}
