using ISignupRepositoryNamespace;
using MediatR;
using SignupCommandAndHandlerNamespace;
using SignupRepositoryNamespace;
using signupServiceNamespace;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddScoped<ISignupRepository, SignupRepository>();
builder.Services.AddMediatR(typeof(SignupCommandAndHandler));
builder.Services.AddTransient<SignupService>();
var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
