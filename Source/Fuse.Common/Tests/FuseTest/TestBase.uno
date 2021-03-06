using Uno;
using Uno.Collections;
using Uno.Threading;

using Fuse;
using Fuse.Triggers;
using Fuse.Elements;

namespace FuseTest
{
	public class DiagnosticException : Exception
	{
		public Diagnostic Diagnostic;

		public DiagnosticException(Diagnostic d) : base(d.ToString(), d.Exception)
		{
			this.Diagnostic = d;
		}
	}

	public class RecordDiagnosticGuard : IDisposable
	{
		//records all diagnostics that happen since last DequeueAll
		ConcurrentQueue<Diagnostic> _diagnosticsQueue = new ConcurrentQueue<Diagnostic>();

		public IList<Diagnostic> DequeueAll()
		{
			var ret = new List<Diagnostic>();
			while (true)
			{
				Diagnostic d;
				if (!_diagnosticsQueue.TryDequeue(out d))
					break;

				ret.Add(d);
			}

			return ret;
		}

		public RecordDiagnosticGuard()
		{ 
			if (TestBase._allowDiagnostics)
				throw new Exception("Diagnostics already allowed");

			TestBase._allowDiagnostics = true;
			Diagnostics.DiagnosticReported += OnDiagnostic;
		}
		
		void OnDiagnostic(Diagnostic d)
		{
			if (!d.IsTemporalWarning)
				_diagnosticsQueue.Enqueue(d);
		}

		public void Dispose()
		{
			if (!TestBase._allowDiagnostics)
				throw new Exception("Diagnostics not allowed");

			TestBase._allowDiagnostics = false;
			Diagnostics.DiagnosticReported -= OnDiagnostic;

			if (_diagnosticsQueue.Count > 0)
				throw new Exception("Unchecked, queued Diagnostics!");
		}
	}

	public class TestBase
	{
		static readonly Thread MainThread;
		static TestBase()
		{
			MainThread = Thread.CurrentThread;
			Diagnostics.DiagnosticReported += DispatchDiagnostic;
		}

		static internal bool _allowDiagnostics;

		static void DispatchDiagnostic(Diagnostic d)
		{
			if (!_allowDiagnostics)
			{
				if (Thread.CurrentThread == MainThread)
					OnDiagnosticReported(d);
				else
					UpdateManager.PostAction(new DiagnosticDispatch{ Diagnostic = d, Handler = OnDiagnosticReported }.Post);
			}
		}

		static void OnDiagnosticReported(Diagnostic d)
		{
			if (!d.IsTemporalWarning)
				throw new DiagnosticException(d);
		}

		internal class DiagnosticDispatch
		{
			public Diagnostic Diagnostic;
			public DiagnosticHandler Handler;

			public void Post()
			{
				Handler(Diagnostic);
			}
		}

		/**
			Use this rather than access Progress directly. It limits how many projects we have
			to expose Internals to.
		*/
		protected double TriggerProgress( Trigger t )
		{
			return t.Progress;
		}
		
		protected float4 ActualPositionSize( Element e)
		{
			return float4( e.ActualPosition, e.ActualSize );
		}
		
		protected float GestureHardCaptureSignificanceThreshold
		{
			get { return Fuse.Input.Gesture.HardCaptureSignificanceThreshold; }
		}
	}
}
