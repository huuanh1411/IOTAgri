using System;
using System.Reflection;
using System.Threading.Tasks;
using IOTAgriBackend.Models;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Logging.Abstractions;
using Microsoft.Extensions.Options;
using Moq;

namespace IOTAgriBackend.Tests;

internal static class BackendTestDoubles
{
    // Invoke a private Minimal API handler without booting Program.cs, migrations,
    // hosted services, or a server. Signature changes fail loudly in tests.
    internal static async Task<IResult> InvokeHandler(Type type, string name, params object?[] arguments)
    {
        var method = type.GetMethod(name, BindingFlags.NonPublic | BindingFlags.Static)
            ?? throw new MissingMethodException(type.FullName, name);
        return await (Task<IResult>)method.Invoke(null, arguments)!;
    }

    internal static Mock<UserManager<ApplicationUser>> Users() => new(
        Mock.Of<IUserStore<ApplicationUser>>(),
        Options.Create(new IdentityOptions()), new PasswordHasher<ApplicationUser>(),
        Array.Empty<IUserValidator<ApplicationUser>>(), Array.Empty<IPasswordValidator<ApplicationUser>>(),
        new UpperInvariantLookupNormalizer(), new IdentityErrorDescriber(),
        Mock.Of<IServiceProvider>(), NullLogger<UserManager<ApplicationUser>>.Instance);

    internal static Mock<RoleManager<IdentityRole>> Roles() => new(
        Mock.Of<IRoleStore<IdentityRole>>(), Array.Empty<IRoleValidator<IdentityRole>>(),
        new UpperInvariantLookupNormalizer(), new IdentityErrorDescriber(),
        NullLogger<RoleManager<IdentityRole>>.Instance);
}
