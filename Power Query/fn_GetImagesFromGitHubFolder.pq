let
  Quelle =
    let
      fn_GetImagesFromGitHubFolder = (BaseURL as text, FileExtension as text) as table =>
        let
          CleanURL = Text.Replace(
            Text.Replace(BaseURL, "github.com", "raw.githubusercontent.com"),
            "/tree/",
            "/"
          ),
          Quelle = Web.BrowserContents(BaseURL),
          AusHTMLCodeExtrahierteTabelle = Html.Table(
            Quelle,
            {
              {
                "Name",
                "TABLE.Box-sc-g0xbh4-0.cAQuiW > * > TR > TH[colspan=""2""]:not([rowspan]):nth-child(1):nth-last-child(4), 
              TABLE.Box-sc-g0xbh4-0.cAQuiW > * > TR > TD[colspan=""3""]:not([rowspan]):nth-child(1):nth-last-child(1), 
              TABLE.Box-sc-g0xbh4-0.cAQuiW > * > TR > TD[colspan=""2""]:not([rowspan]):nth-child(1):nth-last-child(4)"

                                                                                                                      
              }
            },
            [RowSelector = "TABLE.Box-sc-g0xbh4-0.cAQuiW > * > TR"]
          ),
          HöherGestufteHeader = Table.PromoteHeaders(
            AusHTMLCodeExtrahierteTabelle,
            [PromoteAllScalars = true]
          ),
          GeänderteTypen = Table.TransformColumnTypes(HöherGestufteHeader, {{"Name", type text}}),
          GefilterteZeilen = Table.SelectRows(
            GeänderteTypen,
            each Text.EndsWith([Name], FileExtension)
              and [Name]
              <> "View all files" and [Name]
              <> "parent directory.."
          ),
          HinzugefügteBenutzerdefinierteSpalte = Table.AddColumn(
            GefilterteZeilen,
            "Link (GitHub)",
            each CleanURL & "/" & Uri.EscapeDataString([Name]),
            type text
          ),
          BerechneteIndexSpalte = Table.AddColumn(
            HinzugefügteBenutzerdefinierteSpalte,
            "Bild Nr.",
            each
              if Text.Contains([Name], "_") then
                try Number.FromText(Text.BetweenDelimiters([Name], "_", ".")) otherwise null
              else
                1,
            Int64.Type
          ),
          ExtrahierterTextVorUnterstrich = Table.TransformColumns(
            BerechneteIndexSpalte,
            {{"Name", each Text.BeforeDelimiter(_, "_"), type text}}
          ),
          FinalTable = Table.TransformColumnTypes(
            ExtrahierterTextVorUnterstrich,
            {{"Link (GitHub)", type text}, {"Bild Nr.", Int64.Type}}
          )
        in
          FinalTable,
      // Documentation
      Documentation.Name = "fn_GetImagesFromGitHubFolder",
      Documentation.LongDescription
        = "Lädt Bilder aus einem spezifizierten GitHub-Ordner, der Bilder in verschiedenen Formaten enthält. Transformiert die URLs von der GitHub Repository Ansicht zur direkten Raw-Content-Ansicht und extrahiert relevante Daten aus dem Dateinamen für die Verwendung in Power BI.",
      Documentation.Examples = {
        [
          Description = "Laden von .png Bildern aus einem GitHub-Ordner",
          Code
            = "fn_GetImagesFromGitHubFolder(""https://github.com/your-user/your-repo/tree/main/your-folder"", "".png"")",
          Result = "Tabelle mit Spalten 'Name', 'Link (GitHub)', und 'Index'"
        ]
      }
    in
      fn_GetImagesFromGitHubFolder
in
  Quelle