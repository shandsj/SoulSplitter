// This file is part of the SoulSplitter distribution (https://github.com/FrankvdStam/SoulSplitter).
// Copyright (c) 2026 SoulSplitter contributors.
// https://github.com/FrankvdStam/SoulSplitter/blob/main/LICENSE
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3.
//
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
// General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.

using Microsoft.VisualStudio.TestTools.UnitTesting;
using SoulMemory.DarkSouls1;

namespace SoulMemory.Tests;

[TestClass]
public class DarkSoulsRemasteredLocaleTests
{
    private const string SteamId = "123456";

    [TestMethod]
    public void DetectJapaneseSaveDirectory_OnlyJapaneseSaveExists_ReturnsTrue()
    {
        WithDocumentsDirectory(documents =>
        {
            CreateSave(documents, "FromSoftware", DateTime.UtcNow);

            Assert.IsTrue(Remastered.DetectJapaneseSaveDirectory(documents, SteamId));
        });
    }

    [TestMethod]
    public void DetectJapaneseSaveDirectory_OnlyStandardSaveExists_ReturnsFalse()
    {
        WithDocumentsDirectory(documents =>
        {
            CreateSave(documents, "NBGI", DateTime.UtcNow);

            Assert.IsFalse(Remastered.DetectJapaneseSaveDirectory(documents, SteamId));
        });
    }

    [TestMethod]
    public void DetectJapaneseSaveDirectory_BothSavesExist_UsesMostRecentlyWrittenSave()
    {
        WithDocumentsDirectory(documents =>
        {
            var now = DateTime.UtcNow;
            CreateSave(documents, "FromSoftware", now.AddMinutes(-5));
            CreateSave(documents, "NBGI", now);

            Assert.IsFalse(Remastered.DetectJapaneseSaveDirectory(documents, SteamId));

            File.SetLastWriteTimeUtc(
                GetSavePath(documents, "FromSoftware"),
                now.AddMinutes(5));

            Assert.IsTrue(Remastered.DetectJapaneseSaveDirectory(documents, SteamId));
        });
    }

    [TestMethod]
    public void DetectJapaneseSaveDirectory_OnlyJapaneseDirectoryExists_ReturnsTrue()
    {
        WithDocumentsDirectory(documents =>
        {
            Directory.CreateDirectory(Path.GetDirectoryName(GetSavePath(documents, "FromSoftware"))!);

            Assert.IsTrue(Remastered.DetectJapaneseSaveDirectory(documents, SteamId));
        });
    }

    [TestMethod]
    public void DetectJapaneseSaveDirectory_BothDirectoriesExistWithoutSaves_ReturnsFalse()
    {
        WithDocumentsDirectory(documents =>
        {
            Directory.CreateDirectory(Path.GetDirectoryName(GetSavePath(documents, "FromSoftware"))!);
            Directory.CreateDirectory(Path.GetDirectoryName(GetSavePath(documents, "NBGI"))!);

            Assert.IsFalse(Remastered.DetectJapaneseSaveDirectory(documents, SteamId));
        });
    }

    private static void WithDocumentsDirectory(Action<string> action)
    {
        var documents = Path.Combine(Path.GetTempPath(), $"SoulSplitterLocaleTests-{Guid.NewGuid():N}");
        Directory.CreateDirectory(documents);

        try
        {
            action(documents);
        }
        finally
        {
            Directory.Delete(documents, recursive: true);
        }
    }

    private static void CreateSave(string documents, string localeFolder, DateTime lastWriteTimeUtc)
    {
        var save = GetSavePath(documents, localeFolder);
        Directory.CreateDirectory(Path.GetDirectoryName(save)!);
        File.WriteAllText(save, "test save");
        File.SetLastWriteTimeUtc(save, lastWriteTimeUtc);
    }

    private static string GetSavePath(string documents, string localeFolder)
    {
        return Path.Combine(
            documents,
            localeFolder,
            "DARK SOULS REMASTERED",
            SteamId,
            "DRAKS0005.sl2");
    }
}
