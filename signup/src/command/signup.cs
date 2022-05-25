using MediatR;
using RegisterFormModelNamespace;
using signupServiceNamespace;

namespace SignupCommandAndHandlerNamespace
{
    public static class SignupCommandAndHandler
    {
        public record SignupCommand(RegistrationFormModel users) : IRequest<string>;
        public class SignupHandler : IRequestHandler<SignupCommand, string>
        {

            private readonly SignupService _svc;
            public SignupHandler(SignupService svc)
            {
                _svc = svc;
            }

            public Task<string> Handle(SignupCommand request, CancellationToken cancellationToken)
            {
                var _results = _svc.signupServiceFunc(request.users);
                return Task.FromResult(_results);
            }
        }
    }
}