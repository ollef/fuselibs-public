using Uno;
using Uno.Collections;
using Uno.Graphics;
using Fuse;
using Fuse.Controls;
using Uno.Testing;
using FuseTest;
using Fuse.Resources;
using Fuse.Elements;
using FuseTest;
using Fuse.Controls.Test.Helpers;

namespace Fuse.Controls.Test
{
	public class PanelTest : TestBase
	{
		[Test]
		public void AllElementProps()
		{
			var p = new Panel();
			ElementPropertyTester.All(p);
		}

		[Test]
		public void AllElementLayoutTest()
		{
			var p = new Panel();
			ElementLayoutTester.All(p);
		}

		[Test]
		public void AddChildrensTest()
		{
			var panel = new Panel();
			PanelTester.AddChildrensTest(panel);
		}

		[Test]
		public void AddAndRemoveChildrensTest()
		{
			var panel = new Panel();
			PanelTester.AddAndRemoveChildrensTest(panel);
		}

		[Test]
		public void HasChildrenTest()
		{
			var panel = new Panel();
			PanelTester.HasChildrenTest(panel);
		}

		[Test]
		public void LayoutAlignment()
		{
			var panel = new Panel();
			PanelTester.LayoutAlignment(panel);
		}

		[Test]
		public void SnappingToPixels()
		{
			var panel = new Panel();
			PanelTester.SnappingToPixels(panel);
		}

		[Test]
		public void MaxAndMinWidthTest()
		{
			var panel = new Panel();
			PanelTester.MaxAndMinWidthTest(panel);
		}

		[Test]
		public void MaxAndMinHeightTest()
		{
			var panel = new Panel();
			PanelTester.MaxAndMinHeightTest(panel);
		}

		[Test]
		public void LayoutCenterAlignment()
		{
			var root = new TestRootPanel();
			var parent = new Panel();
			root.Children.Add(parent);

			var child1 = new Panel();
			child1.Margin = float4( 10, 5, 20, 15 );
			child1.Width = 100;
			child1.Height = 50;
			child1.Alignment = Alignment.Left;
			parent.Children.Add( child1 );

			var child2 = new Panel();
			child2.Margin = float4( 10, 5, 0, 15 );
			child2.Width = 300;
			child2.Height = 200;
			child2.Alignment = Alignment.Top;
			parent.Children.Add( child2 );

			root.Layout(int2(320, 240));
			LayoutTestHelper.TestElementLayout(child1, float2(100, 50), float2(10, 240/2 - (50-5+15)/2));
			LayoutTestHelper.TestElementLayout(child2, float2(300, 200), float2(320/2 - (300-10)/2, 5));
		}

		[Test]
		public void PanelPaddingTest()
		{
	        var root = new TestRootPanel();
			var parent = new Panel();
			root.Children.Add(parent);

			PanelTester.FillPanelProperties(parent, float4( 0, 0, 0, 0 ), 200, 50, Alignment.TopLeft);
			parent.Padding = float4(11,12,13,7);

			var child = new Panel();
			parent.Children.Add(child);

			root.Layout(int2(1000,500));
			LayoutTestHelper.TestElementLayout(child, float2(200-11-13,50-7-12), float2(11,12));

			parent.Padding = float4(0,0,0,0);
			root.Layout(int2(1000,500));
			LayoutTestHelper.TestElementLayout(child, float2(200,50), float2(0,0));
		}
		
		//This feature of two-pass panel layout has been removed
		/*
		[Test]
		public void LayoutPercentDepend()
		{
			var root = new TestRootPanel(true);
			var p = new UX.LayoutPercentDepend();
			root.Children.Add(p);
			
			root.Layout(int2(500,500));
			LayoutTestHelper.TestElementLayout(p, float2(100,25), float2((500-100)/2f,(500-25)/2f));
			LayoutTestHelper.TestElementLayout(p.c2, float2(50,25), float2(50,0));
			LayoutTestHelper.TestElementLayout(p.c3, float2(10,2.5f), float2(0)); //NOTE: height may actually be defined as 1 here
		}
		*/
		
		[Test]
		public void LayoutOffset()
		{
			var root = new TestRootPanel();
			var p = new UX.LayoutOffset();
			root.Children.Add(p);
			
			root.Layout(int2(1000,400));
			LayoutTestHelper.TestElementLayout(p.r1, float2(10,10), float2(2,3) );
			LayoutTestHelper.TestElementLayout(p.r2, float2(10,10), float2(1000-13,400-14) );
			LayoutTestHelper.TestElementLayout(p.r3, float2(10,10), float2(750-5,300-5));
		}
		
		[Test]
		public void ElementAnchor()
		{
			var root = new TestRootPanel();
			var p = new UX.ElementAnchor();
			root.Children.Add(p);
			
			root.Layout(int2(400,1000));
			LayoutTestHelper.TestElementLayout(p.r1, float2(50,30), float2(150,500-15));
			LayoutTestHelper.TestElementLayout(p.r2, float2(20,10), float2(-6,1000-8));
		}
		
		[Test]
		public void MaxWidthHeight()
		{
			var root = new TestRootPanel();
			var p = new UX.MaxWidthHeight();
			root.Children.Add(p);
			
			root.Layout(int2(1000));
			Assert.AreEqual(float2(500,400), p.P1.ActualSize);
			Assert.AreEqual(float2(200,600), p.P2.ActualSize);
			Assert.AreEqual(float2(200,400), p.P3.ActualSize);
			Assert.AreEqual(float2(200,400), p.P4.ActualSize);
			Assert.AreEqual(float2(500,600), p.P5.ActualSize);
			Assert.AreEqual(float2(200,400), p.P6.ActualSize);
			Assert.AreEqual(float2(100,300), p.P7.ActualSize);
		}
		
		[Test]
		public void InvalidateDepend()
		{
			var root = new TestRootPanel();
			var p = new UX.InvalidateDepend();
			root.Children.Add(p);
			
			root.Layout(int2(1000));
			p.T1.InvalidateLayout();
			Assert.AreEqual(InvalidateLayoutReason.MarginBoxChanged, p.T1.LayoutDirty);
			Assert.AreEqual(InvalidateLayoutReason.MarginBoxChanged, p.P1.LayoutDirty);
			Assert.AreEqual(InvalidateLayoutReason.ChildChanged, p.LayoutDirty);
			Assert.AreEqual(InvalidateLayoutReason.NothingChanged, p.P2.LayoutDirty);
			
			root.Layout(int2(1000));
			p.T2.InvalidateLayout();
			Assert.AreEqual(InvalidateLayoutReason.MarginBoxChanged, p.T2.LayoutDirty);
			Assert.AreEqual(InvalidateLayoutReason.MarginBoxChanged, p.P3.LayoutDirty);
			Assert.AreEqual(InvalidateLayoutReason.ChildChanged, p.LayoutDirty);
			
			root.Layout(int2(1000));
			p.GP2.InvalidateLayout();
			Assert.AreEqual(InvalidateLayoutReason.MarginBoxChanged, p.GP2.LayoutDirty);
			Assert.AreEqual(InvalidateLayoutReason.ChildChanged, p.G1.LayoutDirty);
			Assert.AreEqual(InvalidateLayoutReason.ChildChanged, p.LayoutDirty);
			
			root.Layout(int2(1000));
			p.T3.InvalidateLayout();
			Assert.AreEqual(InvalidateLayoutReason.MarginBoxChanged, p.T3.LayoutDirty);
			Assert.AreEqual(InvalidateLayoutReason.ChildChanged, p.GP1.LayoutDirty);
			Assert.AreEqual(InvalidateLayoutReason.ChildChanged, p.G1.LayoutDirty);
			Assert.AreEqual(InvalidateLayoutReason.ChildChanged, p.LayoutDirty);
			
			root.Layout(int2(1000));
			p.N1.InvalidateLayout();
			Assert.AreEqual(InvalidateLayoutReason.MarginBoxChanged, p.N1.LayoutDirty);
			Assert.AreEqual(InvalidateLayoutReason.MarginBoxChanged, p.T3.LayoutDirty);
			Assert.AreEqual(InvalidateLayoutReason.ChildChanged, p.GP1.LayoutDirty);
			Assert.AreEqual(InvalidateLayoutReason.ChildChanged, p.G1.LayoutDirty);
			Assert.AreEqual(InvalidateLayoutReason.ChildChanged, p.LayoutDirty);
			
			root.Layout(int2(1000));
			p.GP3.InvalidateLayout();
			Assert.AreEqual(InvalidateLayoutReason.MarginBoxChanged, p.GP3.LayoutDirty);
			Assert.AreEqual(InvalidateLayoutReason.ChildChanged, p.G1.LayoutDirty);
			
			root.Layout(int2(1000));
			p.N2.InvalidateLayout();
			Assert.AreEqual(InvalidateLayoutReason.MarginBoxChanged, p.N2.LayoutDirty);
			Assert.AreEqual(InvalidateLayoutReason.ChildChanged, p.T4.LayoutDirty);
			Assert.AreEqual(InvalidateLayoutReason.ChildChanged, p.G1.LayoutDirty);

			root.Layout(int2(1000));
			p.N3.InvalidateLayout();
			Assert.AreEqual(InvalidateLayoutReason.MarginBoxChanged, p.N3.LayoutDirty);
			Assert.AreEqual(InvalidateLayoutReason.ChildChanged, p.P4.LayoutDirty);
			
			root.Layout(int2(1000));
			p.SD1.InvalidateLayout();
			Assert.AreEqual(InvalidateLayoutReason.MarginBoxChanged, p.SD1.LayoutDirty);
			Assert.AreEqual(InvalidateLayoutReason.MarginBoxChanged, p.ST1.LayoutDirty);
			Assert.AreEqual(InvalidateLayoutReason.MarginBoxChanged, p.S1.LayoutDirty);
			Assert.AreEqual(InvalidateLayoutReason.ChildChanged, p.LayoutDirty);
		}
		
		[Test]
		public void Issue1063()
		{
			var root = new TestRootPanel();
			var p = new UX.RemovingAnimationRoot();
			root.Children.Add(p);
			
			root.Layout(int2(1000));
			root.IncrementFrame();
			
			p.innerPanel.Value = false;
			root.IncrementFrame(0.1f);
			Assert.IsTrue(p.B.Children.Contains(p.C));
			root.IncrementFrame(2);
			root.IncrementFrame(0.1f); //TODO: shouldn't be required (one frame delayed)
			Assert.IsFalse(p.B.Children.Contains(p.C));

			//reenabled while deleting.
			p.innerPanel.Value = true;
			Assert.IsTrue(p.B.Children.Contains(p.C));
			p.innerPanel.Value = false;
			root.IncrementFrame(0.1f);
			root.IncrementFrame(0.1f);
			p.innerPanel.Value = true;
			Assert.IsTrue(p.B.Children.Contains(p.C));
			
			//remove outer while removing
			p.innerPanel.Value = false;
			root.IncrementFrame(0.1f);
			p.outerPanel.Value = false;
			root.IncrementFrame(0.1f);
			Assert.IsFalse(p.A.Children.Contains(p.B));
			Assert.IsFalse(p.B.Children.Contains(p.C));
			
			p.outerPanel.Value = true;
			root.IncrementFrame(0.1f);
			Assert.IsTrue(p.A.Children.Contains(p.B));
			Assert.IsFalse(p.B.Children.Contains(p.C));
			
			//remove inner while outer not visible
			p.innerPanel.Value = true;
			root.IncrementFrame(0.1f);
			Assert.IsTrue(p.B.Children.Contains(p.C));
			p.outerPanel.Value = false;
			Assert.IsFalse(p.A.Children.Contains(p.B));
			p.innerPanel.Value = false;
			Assert.IsFalse(p.B.Children.Contains(p.C));
		}
		
		[Test]
		public void ZOrder()
		{
			var root = new TestRootPanel();
			var p = new UX.ZOrderTest();
			root.Children.Add(p);
			
			var order = new Panel[]{ p.B2, p.B1, p.S2, p.S1, p.S3, p.O2, p.O1 };
			for (int i=0; i < p.ZOrderChildCount; i++)
				Assert.AreEqual(order[i], p.GetZOrderChild(i));
				
			p.S1.ZOffset = 2;
			p.O1.ZOffset = -1;
			order = new Panel[]{ p.B2, p.B1, p.S2, p.S3, p.S1, p.O1, p.O2 };
			for (int i=0; i < p.ZOrderChildCount; i++)
				Assert.AreEqual(order[i], p.GetZOrderChild(i));
		}
	}
}
