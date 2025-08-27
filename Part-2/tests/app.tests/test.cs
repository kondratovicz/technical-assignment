using System;
using Xunit;

namespace app.tests;

public class Test
{
    [Fact]
    public void Hello()
    {
        var originalOut = Console.Out;
        
        try
        {
            using var writer = new StringWriter();
            Console.SetOut(writer);
            
            Console.WriteLine("Hello!");
            
            var output = writer.ToString();
            Assert.Contains("Hello!", output);
        }
        finally
        {
            Console.SetOut(originalOut);
        }
    }
}