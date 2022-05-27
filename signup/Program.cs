using SignupCommandAndHandlerNamespace;
using ISignupRepositoryNamespace;
using SignupRepositoryNamespace;
using signupServiceNamespace;
using MediatR;
using ISignupServiceNamespace;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddScoped<ISignupRepository, SignupRepository>();
builder.Services.AddMediatR(typeof(SignupCommandAndHandler));
builder.Services.AddScoped<ISignupService, SignupService>();

// Add CORS
var MskCorsConfiguration = "MskCorsConfiguration";

builder.Services.AddCors(options =>
{
    options.AddPolicy(MskCorsConfiguration,
        policy =>
        {
            policy.AllowAnyOrigin()
            .AllowAnyHeader()
            .AllowAnyMethod();
        });
});

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors(MskCorsConfiguration);

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
