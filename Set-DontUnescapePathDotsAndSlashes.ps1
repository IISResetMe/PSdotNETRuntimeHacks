function Set-DontUnescapePathDotsAndSlashes
{
    param(
        [ValidateNotNull()]
        [Parameter(Mandatory)]
        [Uri]$uri
    )

    # Retrieve the private Syntax field from the uri class,
    # this is our indirect reference to the attached parser
    $syntaxFieldInfo = $uri.GetType().GetField('m_Syntax', 'NonPublic,Instance')
    if (-not $syntaxFieldInfo)
    {
        throw [System.MissingFieldException]"'m_Syntax' field not found"
        return
    }

    # Retrieve the private Flags field from the parser class,
    # this is the value we're looking to update at runtime
    $flagsFieldInfo = [System.UriParser].GetField('m_Flags', 'NonPublic,Instance')
    if (-not $flagsFieldInfo){
        throw [System.MissingFieldException]"'m_Flags' field not found"
        return
    }

    # Retrieve the actual instances
    $uriParser = $syntaxFieldInfo.GetValue($uri)
    $uriSyntaxFlags = $flagsFieldInfo.GetValue($uriParser)

    # Define the bit flags we want to remove
    $UnEscapeDotsAndSlashes = 0x2000000
    $SimpleUserSyntax = 0x20000

    # Clear the flags that we don't want
    $uriSyntaxFlags = [int]$uriSyntaxFlags -band -bnot($UnEscapeDotsAndSlashes)
    $uriSyntaxFlags = [int]$uriSyntaxFlags -band -bnot($SimpleUserSyntax)

    # Overwrite the existing Flags field
    $flagsFieldInfo.SetValue($uriParser, $uriSyntaxFlags)
}
