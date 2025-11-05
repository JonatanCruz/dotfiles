-- diffview.nvim - Advanced Git Diff and Merge Conflict Resolution
-- UI superior para diffs y resolución de conflictos vs gitsigns básico

return {
  "sindrets/diffview.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  cmd = {
    "DiffviewOpen",
    "DiffviewClose",
    "DiffviewToggleFiles",
    "DiffviewFocusFiles",
    "DiffviewRefresh",
    "DiffviewFileHistory",
  },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Open Diff View" },
    { "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "Close Diff View" },
    { "<leader>gh", "<cmd>DiffviewFileHistory<cr>", desc = "File History (all)" },
    { "<leader>gH", "<cmd>DiffviewFileHistory %<cr>", desc = "File History (current)" },
    { "<leader>gm", "<cmd>DiffviewOpen HEAD<cr>", desc = "Merge Conflicts" },
    { "<leader>gc", "<cmd>DiffviewOpen HEAD~1<cr>", desc = "Last Commit" },
  },
  opts = {
    diff_binaries = false,
    enhanced_diff_hl = true,
    git_cmd = { "git" },
    hg_cmd = { "hg" },
    use_icons = true,
    show_help_hints = true,
    watch_index = true,

    icons = {
      folder_closed = "",
      folder_open = "",
    },

    signs = {
      fold_closed = "",
      fold_open = "",
      done = "✓",
    },

    view = {
      default = {
        layout = "diff2_horizontal",
        winbar_info = true,
      },
      merge_tool = {
        layout = "diff3_horizontal",
        disable_diagnostics = true,
        winbar_info = true,
      },
      file_history = {
        layout = "diff2_horizontal",
        winbar_info = true,
      },
    },

    file_panel = {
      listing_style = "tree",
      tree_options = {
        flatten_dirs = true,
        folder_statuses = "only_folded",
      },
      win_config = {
        position = "left",
        width = 35,
        win_opts = {},
      },
    },

    file_history_panel = {
      log_options = {
        git = {
          single_file = {
            diff_merges = "combined",
          },
          multi_file = {
            diff_merges = "first-parent",
          },
        },
      },
      win_config = {
        position = "bottom",
        height = 16,
        win_opts = {},
      },
    },

    commit_log_panel = {
      win_config = {
        win_opts = {},
      },
    },

    default_args = {
      DiffviewOpen = {},
      DiffviewFileHistory = {},
    },

    hooks = {},

    keymaps = {
      disable_defaults = false,
      view = {
        { "n", "<tab>", "<cmd>DiffviewToggleFiles<cr>", { desc = "Toggle file panel" } },
        { "n", "gf", "<cmd>DiffviewFocusFiles<cr>", { desc = "Focus file panel" } },
        { "n", "g<C-x>", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
        {
          "n",
          "[x",
          "<cmd>lua require'diffview.actions'.prev_conflict()<cr>",
          { desc = "Previous conflict" },
        },
        {
          "n",
          "]x",
          "<cmd>lua require'diffview.actions'.next_conflict()<cr>",
          { desc = "Next conflict" },
        },
        {
          "n",
          "<leader>co",
          "<cmd>lua require'diffview.actions'.conflict_choose('ours')<cr>",
          { desc = "Choose ours" },
        },
        {
          "n",
          "<leader>ct",
          "<cmd>lua require'diffview.actions'.conflict_choose('theirs')<cr>",
          { desc = "Choose theirs" },
        },
        {
          "n",
          "<leader>cb",
          "<cmd>lua require'diffview.actions'.conflict_choose('base')<cr>",
          { desc = "Choose base" },
        },
        {
          "n",
          "<leader>ca",
          "<cmd>lua require'diffview.actions'.conflict_choose('all')<cr>",
          { desc = "Choose all" },
        },
        {
          "n",
          "dx",
          "<cmd>lua require'diffview.actions'.conflict_choose('none')<cr>",
          { desc = "Delete conflict" },
        },
      },
      file_panel = {
        { "n", "j", "<cmd>lua require'diffview.actions'.next_entry()<cr>", { desc = "Next entry" } },
        { "n", "<down>", "<cmd>lua require'diffview.actions'.next_entry()<cr>", { desc = "Next entry" } },
        { "n", "k", "<cmd>lua require'diffview.actions'.prev_entry()<cr>", { desc = "Previous entry" } },
        { "n", "<up>", "<cmd>lua require'diffview.actions'.prev_entry()<cr>", { desc = "Previous entry" } },
        { "n", "<cr>", "<cmd>lua require'diffview.actions'.select_entry()<cr>", { desc = "Open diff" } },
        { "n", "o", "<cmd>lua require'diffview.actions'.select_entry()<cr>", { desc = "Open diff" } },
        {
          "n",
          "<2-LeftMouse>",
          "<cmd>lua require'diffview.actions'.select_entry()<cr>",
          { desc = "Open diff" },
        },
        {
          "n",
          "-",
          "<cmd>lua require'diffview.actions'.toggle_stage_entry()<cr>",
          { desc = "Stage / unstage" },
        },
        { "n", "S", "<cmd>lua require'diffview.actions'.stage_all()<cr>", { desc = "Stage all" } },
        { "n", "U", "<cmd>lua require'diffview.actions'.unstage_all()<cr>", { desc = "Unstage all" } },
        { "n", "X", "<cmd>lua require'diffview.actions'.restore_entry()<cr>", { desc = "Restore entry" } },
        {
          "n",
          "L",
          "<cmd>lua require'diffview.actions'.open_commit_log()<cr>",
          { desc = "Open commit log" },
        },
        { "n", "zo", "<cmd>lua require'diffview.actions'.open_fold()<cr>", { desc = "Expand fold" } },
        { "n", "h", "<cmd>lua require'diffview.actions'.close_fold()<cr>", { desc = "Close fold" } },
        { "n", "zc", "<cmd>lua require'diffview.actions'.close_fold()<cr>", { desc = "Close fold" } },
        { "n", "za", "<cmd>lua require'diffview.actions'.toggle_fold()<cr>", { desc = "Toggle fold" } },
        { "n", "zR", "<cmd>lua require'diffview.actions'.open_all_folds()<cr>", { desc = "Open all folds" } },
        { "n", "zM", "<cmd>lua require'diffview.actions'.close_all_folds()<cr>", { desc = "Close all folds" } },
        {
          "n",
          "<c-b>",
          "<cmd>lua require'diffview.actions'.scroll_view(-0.25)<cr>",
          { desc = "Scroll up" },
        },
        {
          "n",
          "<c-f>",
          "<cmd>lua require'diffview.actions'.scroll_view(0.25)<cr>",
          { desc = "Scroll down" },
        },
        {
          "n",
          "<tab>",
          "<cmd>lua require'diffview.actions'.select_next_entry()<cr>",
          { desc = "Next file" },
        },
        {
          "n",
          "<s-tab>",
          "<cmd>lua require'diffview.actions'.select_prev_entry()<cr>",
          { desc = "Previous file" },
        },
        { "n", "gf", "<cmd>lua require'diffview.actions'.goto_file_edit()<cr>", { desc = "Go to file" } },
        {
          "n",
          "<C-w><C-f>",
          "<cmd>lua require'diffview.actions'.goto_file_split()<cr>",
          { desc = "Go to file (split)" },
        },
        {
          "n",
          "<C-w>gf",
          "<cmd>lua require'diffview.actions'.goto_file_tab()<cr>",
          { desc = "Go to file (tab)" },
        },
        {
          "n",
          "i",
          "<cmd>lua require'diffview.actions'.listing_style()<cr>",
          { desc = "Toggle listing style" },
        },
        {
          "n",
          "f",
          "<cmd>lua require'diffview.actions'.toggle_flatten_dirs()<cr>",
          { desc = "Toggle flatten" },
        },
        { "n", "R", "<cmd>DiffviewRefresh<cr>", { desc = "Refresh" } },
        { "n", "<leader>e", "<cmd>lua require'diffview.actions'.focus_files()<cr>", { desc = "Focus files" } },
        { "n", "<leader>b", "<cmd>lua require'diffview.actions'.toggle_files()<cr>", { desc = "Toggle panel" } },
        { "n", "g<C-x>", "<cmd>DiffviewClose<cr>", { desc = "Close" } },
        { "n", "[x", "<cmd>lua require'diffview.actions'.prev_conflict()<cr>", { desc = "Prev conflict" } },
        { "n", "]x", "<cmd>lua require'diffview.actions'.next_conflict()<cr>", { desc = "Next conflict" } },
      },
      file_history_panel = {
        { "n", "g!", "<cmd>lua require'diffview.actions'.options()<cr>", { desc = "Options" } },
        {
          "n",
          "<C-A-d>",
          "<cmd>lua require'diffview.actions'.open_in_diffview()<cr>",
          { desc = "Open in diffview" },
        },
        { "n", "y", "<cmd>lua require'diffview.actions'.copy_hash()<cr>", { desc = "Copy hash" } },
        {
          "n",
          "L",
          "<cmd>lua require'diffview.actions'.open_commit_log()<cr>",
          { desc = "Commit log" },
        },
        { "n", "zR", "<cmd>lua require'diffview.actions'.open_all_folds()<cr>", { desc = "Open all folds" } },
        { "n", "zM", "<cmd>lua require'diffview.actions'.close_all_folds()<cr>", { desc = "Close all folds" } },
        { "n", "j", "<cmd>lua require'diffview.actions'.next_entry()<cr>", { desc = "Next entry" } },
        { "n", "<down>", "<cmd>lua require'diffview.actions'.next_entry()<cr>", { desc = "Next entry" } },
        { "n", "k", "<cmd>lua require'diffview.actions'.prev_entry()<cr>", { desc = "Previous entry" } },
        { "n", "<up>", "<cmd>lua require'diffview.actions'.prev_entry()<cr>", { desc = "Previous entry" } },
        { "n", "<cr>", "<cmd>lua require'diffview.actions'.select_entry()<cr>", { desc = "Open diff" } },
        { "n", "o", "<cmd>lua require'diffview.actions'.select_entry()<cr>", { desc = "Open diff" } },
        {
          "n",
          "<2-LeftMouse>",
          "<cmd>lua require'diffview.actions'.select_entry()<cr>",
          { desc = "Open diff" },
        },
        {
          "n",
          "<c-b>",
          "<cmd>lua require'diffview.actions'.scroll_view(-0.25)<cr>",
          { desc = "Scroll up" },
        },
        {
          "n",
          "<c-f>",
          "<cmd>lua require'diffview.actions'.scroll_view(0.25)<cr>",
          { desc = "Scroll down" },
        },
        {
          "n",
          "<tab>",
          "<cmd>lua require'diffview.actions'.select_next_entry()<cr>",
          { desc = "Next file" },
        },
        {
          "n",
          "<s-tab>",
          "<cmd>lua require'diffview.actions'.select_prev_entry()<cr>",
          { desc = "Previous file" },
        },
        { "n", "gf", "<cmd>lua require'diffview.actions'.goto_file_edit()<cr>", { desc = "Go to file" } },
        {
          "n",
          "<C-w><C-f>",
          "<cmd>lua require'diffview.actions'.goto_file_split()<cr>",
          { desc = "Go to file (split)" },
        },
        {
          "n",
          "<C-w>gf",
          "<cmd>lua require'diffview.actions'.goto_file_tab()<cr>",
          { desc = "Go to file (tab)" },
        },
        { "n", "<leader>e", "<cmd>lua require'diffview.actions'.focus_files()<cr>", { desc = "Focus files" } },
        { "n", "<leader>b", "<cmd>lua require'diffview.actions'.toggle_files()<cr>", { desc = "Toggle panel" } },
        { "n", "g<C-x>", "<cmd>DiffviewClose<cr>", { desc = "Close" } },
      },
      option_panel = {
        { "n", "<tab>", "<cmd>lua require'diffview.actions'.select_entry()<cr>", { desc = "Select entry" } },
        { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close" } },
      },
      help_panel = {
        { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close" } },
      },
    },
  },
}
