namespace IOTAgriBackend.Services;

public static class AdminRoleRules
{
    public static string? Validate(string actorUserId, string targetUserId, string? role, bool targetIsAdmin, int adminCount)
    {
        if (role is not "User" and not "Admin") return "Role must be User or Admin.";
        if (actorUserId == targetUserId) return "Administrators cannot change their own role.";
        if (targetIsAdmin && role == "User" && adminCount <= 1) return "Cannot remove the last administrator.";
        return null;
    }

    public static string? ValidateLock(string actorUserId, string targetUserId, bool isLocked, bool targetIsAdmin, int adminCount)
    {
        if (actorUserId == targetUserId) return "Administrators cannot lock their own account.";
        if (isLocked && targetIsAdmin && adminCount <= 1) return "Cannot lock the last administrator.";
        return null;
    }
}
