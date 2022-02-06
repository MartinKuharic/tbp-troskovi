using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace TBP_obracun_troskova_projekt
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
           
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            // TODO: This line of code loads data into the 'dataSet11.izracun_godisnjeg_odmora' table. You can move, or remove it, as needed.
            this.izracun_godisnjeg_odmoraTableAdapter.Fill(this.dataSet11.izracun_godisnjeg_odmora);
            // TODO: This line of code loads data into the 'dataSet11.izracun_bonusa_djeca' table. You can move, or remove it, as needed.
            this.izracun_bonusa_djecaTableAdapter.Fill(this.dataSet11.izracun_bonusa_djeca);
            // TODO: This line of code loads data into the 'dataSet11.obracun' table. You can move, or remove it, as needed.
            this.obracunTableAdapter.Fill(this.dataSet11.obracun);
            // TODO: This line of code loads data into the 'dataSet11.isplata' table. You can move, or remove it, as needed.
            this.isplataTableAdapter.Fill(this.dataSet11.isplata);
            // TODO: This line of code loads data into the 'dataSet11.davanja' table. You can move, or remove it, as needed.
            this.davanjaTableAdapter.Fill(this.dataSet11.davanja);
            // TODO: This line of code loads data into the 'dataSet11.radno_mjesto' table. You can move, or remove it, as needed.
            this.radno_mjestoTableAdapter.Fill(this.dataSet11.radno_mjesto);
            // TODO: This line of code loads data into the 'dataSet11.godisni_odmor' table. You can move, or remove it, as needed.
            this.godisni_odmorTableAdapter.Fill(this.dataSet11.godisni_odmor);
            // TODO: This line of code loads data into the 'dataSet1.bonusi' table. You can move, or remove it, as needed.
            this.bonusiTableAdapter.Fill(this.dataSet1.bonusi);
            // TODO: This line of code loads data into the 'dataSet1.poduzece' table. You can move, or remove it, as needed.
            this.poduzeceTableAdapter.Fill(this.dataSet1.poduzece);
            // TODO: This line of code loads data into the 'dataSet1.radnik' table. You can move, or remove it, as needed.
            this.radnikTableAdapter.Fill(this.dataSet1.radnik);

        }

        private void label2_Click(object sender, EventArgs e)
        {

        }

        private void btnDodaj_Click(object sender, EventArgs e)
        {
            Cursor.Current = Cursors.WaitCursor;
            try
            {
                radnikBindingSource.EndEdit();
                radnikTableAdapter.Update(this.dataSet1.radnik);
                MessageBox.Show("Uspjesno spremljeno.", "Message", MessageBoxButtons.OK, MessageBoxIcon.Information);
            }
            catch (Exception ex)

            {
                MessageBox.Show(ex.Message, "Message", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            Cursor.Current = Cursors.Default;
            
        }

        private void dataGridView1_KeyDown(object sender, KeyEventArgs e)
        {
            if(e.KeyCode == Keys.Delete)
            {
                if (MessageBox.Show("Jeste li sigurni da zelite izbrisati ovaj redak ? ", "Message", MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.Yes)
                    radnikBindingSource.RemoveCurrent();
            }
        }
    }
}
