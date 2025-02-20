using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.Mvc;

namespace Dormo.Server.Controllers;

[ApiController]
public class ErrorController : ControllerBase
{
    [Route("/error")]
    public IActionResult HandleError()
    {
        var context = HttpContext.Features.Get<IExceptionHandlerFeature>();
        var exception = context?.Error; // Your exception
        var code = 500; // Internal Server Error by default

        // You can add more specific exception handling here if needed

        return Problem(detail: exception?.Message, statusCode: code);
    }
}