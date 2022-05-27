using MediatR;
using Microsoft.AspNetCore.Mvc;
using RegisterFormModelNamespace;
using SignupCommandAndHandlerNamespace;

namespace SignupControllerNamespace
{
    [ApiController]
    [Route("[controller]")]
    public class SignupController : ControllerBase
    {
        private readonly IMediator _mediator;

        public SignupController(IMediator mediator)
        {
            _mediator = mediator;
        }

        [HttpPost]
        public async Task<IActionResult> createAccount(RegistrationFormModel user)
        {
            var _results = await _mediator.Send(new SignupCommandAndHandler.SignupCommand(user));
            return Ok(_results);
        }

        [HttpGet]
        public IActionResult welcome()
        {
            return Ok("Welcome to Eleventh Epfs Api");
        }
    }
}