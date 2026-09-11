Python path · [All steps](index.md) · [Change language](../r/index.md)

Lesson 1 of 6

# Find the plotting function

Keep the example workspace open in VS Code. In Explorer, double-click `runs/baseline/summary.png` to keep its tab open; right-click the tab and choose **Split Right**. Click the left editor group when opening code so the image stays visible on the right.

In Copilot Chat, keep the **Local** session target and select **Ask** from the agent-role selector. These controls are separate from the model selector; the [setup page](../../setup/vscode-copilot.md) shows their roles. Paste:

```text
In plotting/plot_summary.py, what controls the overlapping bars and clipped
labels? Read the source and give me a short code map with file/function
references. Explain how the plotting function reaches the saved PNG.
Do not edit files or run commands.
```

Open the cited source in the other editor group. Find `make_summary_figure()`, the bar positions, and the margins. Compare the explanation with the code and the baseline image. If a reference is missing, open `plotting/plot_summary.py` from Explorer yourself and ask about that section.

**Ready for the next step:** you can point to the layout settings that cause the visible problem. The constants describe invented aggregate counts; there are no individual records to investigate.

---

[← Previous: Setup](index.md) · [Next: 2. Specify →](02-specify.md)
